-module(vote_core_test).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

number_result_test() ->
	?assertEqual(
		[{[b,d], 1},{[a], 0},{[c], -1}], 
		vote_core:number_result([[b, d], [sq, a], [c]])).

add_alt_test() ->
	P = vote_core:new(),
	P2 = vote_core:add_alt(1, P),
	?assertEqual([1, sq], vote_core:alts(P2)),
	?assertEqual(lists:sort([
		{{1,1},0},{{1,sq},0},
		{{sq,1},0},{{sq,sq},0}
		]), lists:sort(vote_core:prefs(P2))).

normalize_ballot_test() ->
	?assertEqual([
		{1, 1}, {2, 0}], 
		vote_core:normalize_ballot([{1, 1}, {3, 1}], [1, 2])).

add_ballot_test() ->
	P2 = vote_core:add_alt(1, vote_core:new()),
	P3 = vote_core:add_alt(2, P2),
	P4 = vote_core:add_ballot([{1, -1}, {2, 1}], P3),
	?assertEqual(lists:sort([
		{{1,1},0},{{1,2},0},{{1,sq},0},
		{{2,1},1},{{2,2},0},{{2,sq},1},
		{{sq,1},1},{{sq,2},0},{{sq,sq},0}]), 
		lists:sort(vote_core:prefs(P4))).

result_test() -> 
P2 = vote_core:add_alt(1, vote_core:new()),
	P3 = vote_core:add_alt(2, P2),
	P4 = vote_core:add_ballot([{1, -1}, {2, 1}], P3),
	?assertEqual(
		[{[2], 1}, {[], 0}, {[1], -1}],
		vote_core:result(P4)).