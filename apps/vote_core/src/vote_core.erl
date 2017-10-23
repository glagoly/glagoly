-module(vote_core).
-compile(export_all).

-record(poll, {alts, prefs}).

new() -> #poll{alts = [sq], prefs = #{{sq, sq} => 0}}.

prefs(Poll) -> maps:to_list(Poll#poll.prefs).

alts(Poll) -> Poll#poll.alts.

result(Poll) ->
	P = schulze:init(Poll#poll.prefs),
	S = schulze:strongest_path(P, alts(Poll)),
	number_result(schulze:order(S, alts(Poll))).

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

pop_sq(Order) ->
	lists:foldl(fun(L, {Pos, Cur, Order2}) -> 
		case lists:member(sq, L) of
			true ->  {Cur, Cur + 1, Order2 ++ [lists:delete(sq, L)]};
			_ -> {Pos, Cur + 1, Order2 ++ [L]}
		end
	end, {undefined, 0, []}, Order).

number_result(Order) ->
	{P, L, Order2} = pop_sq(Order),
	lists:zip(lists:seq(P, P - L + 1, -1), Order2).


%% Create a UUID v4 (random) as a base64 string
%% "+" are replaced with "-"
%% source avtobiff/erlang-uuid
uuid() ->
    <<U0:32, U1:16, _:4, U2:12, _:2, U3:30, U4:32>> = crypto:strong_rand_bytes(16),
    U = base64:encode_to_string(<<U0:32, U1:16, 4:4, U2:12, 2#10:2, U3:30, U4:32>>),
    lists:sublist(re:replace(U, "\\+", "-", [global, {return, list}]), 22).