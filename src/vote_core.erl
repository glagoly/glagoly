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

key_group([{Alt, Vote} | L]) ->
	{I, Current, Acc} = lists:foldl(fun({Alt, Vote}, {I, Current, Acc}) -> 
		case Vote of
			I -> {I, Current ++ [Alt], Acc};
			_ -> {Vote, [Alt], Acc ++ [{Current, I}]}
		end
	end, {Vote, [Alt], []}, L),
	Acc ++ [{Current, I}].

single_result(Poll, Ballot) ->
	Alts = lists:delete(sq, alts(Poll)),
	B = normalize_ballot(Ballot, Alts),
	B2 = lists:reverse(lists:keysort(2, B)),
	key_group(B2).


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
	lists:zip(Order2, lists:seq(P, P - L + 1, -1)).


rand_seq(Length, Seed) ->
	_ = rand:seed(exsp, {Seed, Seed, Seed}),
	lists:foldl(fun (E, L) ->
		{H, T} = lists:split(rand:uniform(E) - 1, L),
		H ++ [E] ++ T
	end, [], lists:seq(1, Length)).

random_init(Size, Voters) ->
	V = lists:foldl(fun add_alt/2, new(), lists:seq(1, Size)),
	P = lists:foldl(fun(_, P) ->
		vote_core:add_ballot([
			{A, rand:uniform(11) - 4} || A <- lists:seq(1, Size)
		], P)
	end, V, lists:seq(1, Voters)).

benchmark(Count, Size, Voters) ->
	lists:map(fun(_) ->
		{Init_time, P} = timer:tc(fun random_init/2, [Size, Voters]),
		{Result_time, R} = timer:tc(fun result/1, [P]),
		io:fwrite("Init;~w;Result;~w~n", [Init_time, Result_time])
	end, lists:seq(1, Count)).

%% Create a UUID v4 (random) as a base64 string
%% "+" are replaced with "-"
%% "/" are replaced with "~"
%% source avtobiff/erlang-uuid
uuid() ->
    <<U0:32, U1:16, _:4, U2:12, _:2, U3:30, U4:32>> = crypto:strong_rand_bytes(16),
    U = base64:encode_to_string(<<U0:32, U1:16, 4:4, U2:12, 2#10:2, U3:30, U4:32>>),
    P = [global, {return, list}],
    lists:sublist(re:replace(re:replace(U, "\\/", "\\~", P), "\\+", "-", P), 22).