-module(vote_core).
-compile(export_all).

-record(poll, {alts, prefs}).

new() -> #poll{alts = [sq], prefs = #{{sq, sq} => 0}}.

prefs(Poll) -> maps:to_list(Poll#poll.prefs).

alts(Poll) -> Poll#poll.alts.

maps_copy(Source, Dest, Map) ->	maps:put(Dest, maps:get(Source, Map, 0), Map).

add_alt(Alt, Poll) -> 
	Alts = ordsets:add_element(Alt, Poll#poll.alts),
	#poll{alts = Alts, prefs = lists:foldl(fun(Alt2, Acc) -> 
		Acc2 = maps_copy({sq, Alt2}, {Alt, Alt2}, Acc),
		maps_copy({Alt2, sq}, {Alt2, Alt}, Acc2)
	end, Poll#poll.prefs, Alts)}.

normalize_ballot(Ballot, Alts) -> 
	B = maps:from_list(Ballot), [{Alt, maps:get(Alt, B, 0)} || Alt <- Alts].
 
add_vote({A, Va}, {B, Vb}, Prefs, Weight) when Va > Vb ->
	maps:put({A, B}, maps:get({A, B}, Prefs) + Weight, Prefs);
add_vote({_, V}, {_, V}, Prefs, _) -> Prefs;
add_vote(A, B, Prefs, Weight) -> add_vote(B, A, Prefs, Weight).

add_votes([], Prefs, _) -> Prefs;
add_votes([A | Rest], Prefs, Weight) -> 
	Prefs2 = lists:foldl(fun(B, P) -> add_vote(A, B, P, Weight) end, Prefs, Rest),
	add_votes(Rest, Prefs2, Weight).

add_ballot(Ballot, Poll) -> add_ballot(Ballot, Poll, 1).
add_ballot(Ballot, Poll, Weight) -> 
	B = normalize_ballot(Ballot, alts(Poll)),
	#poll{alts = Poll#poll.alts, prefs = add_votes(B, Poll#poll.prefs, Weight)}.

key_group([]) -> [];
key_group(L) -> key_group_sorted(lists:keysort(1, L)).

key_group_sorted([{Key, Value} | L]) ->
	{I, Current, Acc} = lists:foldl(fun({Key, Value}, {I, Current, Acc}) -> 
		case Key =:= I of
			true -> {I, [Value | Current], Acc};
			_ -> {Key, [Value], [{I, Current} | Acc]}
		end
	end, {Key, [Value], []}, L),
	[{I, Current} | Acc].

%% Create a UUID v4 (random) as a base64 string
%% "+" are replaced with "-"
%% source avtobiff/erlang-uuid
uuid() ->
    <<U0:32, U1:16, _:4, U2:12, _:2, U3:30, U4:32>> = crypto:strong_rand_bytes(16),
    U = base64:encode_to_string(<<U0:32, U1:16, 4:4, U2:12, 2#10:2, U3:30, U4:32>>),
    lists:sublist(re:replace(U, "\\+", "-", [global, {return, list}]), 22).