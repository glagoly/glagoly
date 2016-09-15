-module(vote_core_test).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

key_group_test() ->
	?assertEqual(
		[{10, [12, 11]}, {0, [1]}], vote_core:key_group([{0, 1}, {10, 11}, {10, 12}])).

add_ballot_test() ->
	Poll = vote_core:new([a, b, c]),
	Poll2 = vote_core:add_ballot([[a,b], [c]], [], Poll),
	Poll3 = vote_core:add_ballot([[a]], [[c]], Poll2),
	?assertEqual(
		lists:sort(
		[{{a,a},0},{{a,b},1},{{a,c},2},{{a,sq},2},
		 {{b,a},0},{{b,b},0},{{b,c},2},{{b,sq},1},
		 {{c,a},0},{{c,b},0},{{c,c},0},{{c,sq},1},
		 {{sq,a},0},{{sq,b},0},{{sq,c},1},{{sq,sq},0}
		]),
		lists:sort(vote_core:prefs(Poll3))).


