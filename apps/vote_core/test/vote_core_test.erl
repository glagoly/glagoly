-module(vote_core_test).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

key_group_test() ->
	?assertEqual(
		[{10, [11, 12]}, {0, [1]}], vote_core:key_group([{0, 1}, {10, 11}, {10, 12}])).

transpose_test() ->
	M = [[1,2,3],
		 [4,5,6],
		 [7,8,9]],
	MT = [[1,4,7],
		 [2,5,8],
		 [3,6,9]],
	?assertEqual(MT, vote_core:transpose(M)).
	
init_test() ->
	D = [[nil, 1, 2],
		[3, nil, 4],
		[5, 6, nil]],
	P = [[{nil, nil}, {1, 3}, {2, 5}],
		[{3, 1}, {nil, nil}, {4, 6}],
		[{5, 2}, {6, 4}, {nil, nil}]],
	?assertEqual(P, vote_core:init(D)).

min_d_test() ->
	?assertEqual({14,7}, vote_core:min_d({14,7},{15,6})).	

max_d_test() ->
	?assertEqual({14,7}, vote_core:max_d({14,7},{12,9})).	

%% Sample 1. Page 12
strongest_path_1_test() ->
	P = vote_core:init([
		[nil, 8, 14, 10],
		[13, nil, 6, 2],
		[7, 15, nil, 12],
		[11, 19, 9, nil]]),
	P2 = [[{nil,nil},{14,7},{14,7},{12,9}],
          [{13,8},{nil,nil},{13,8},{12,9}],
          [{13,8},{15,6},{nil,nil},{12,9}],
          [{13,8},{19,2},{13,8},{nil,nil}]],
	?assertEqual(P2, vote_core:strongest_path(P)).

%% Sample 6. Page 26
strongest_path_6_test() ->
	P = vote_core:init([
		[nil, 67, 28, 40],
		[55, nil, 79, 58],
		[36, 59, nil, 45],
		[50, 72, 29, nil]]),
	P2 = [[{nil,nil},{67,55},{67,55},{45,29}],
          [{45,29},{nil,nil},{79,59},{45,29}],
          [{45,29},{45,29},{nil,nil},{45,29}],
          [{50,40},{72,58},{72,58},{nil,nil}]],
	?assertEqual(P2, vote_core:strongest_path(P)).

%% Sample 6. Page 26
order_test() ->
	P = [[{nil,nil},{67,55},{67,55},{45,29}],
          [{45,29},{nil,nil},{79,59},{45,29}],
          [{45,29},{45,29},{nil,nil},{45,29}],
          [{50,40},{72,58},{72,58},{nil,nil}]],
    ?assertEqual([[4],[1],[2],[3]], vote_core:order(P)).

%% Sample 2. Page 16
order_tie_test() ->
	P = [[{nil,nil},{5,4},{5,4},{5,4}],
         [{5,4},{nil,nil},{7,2},{5,4}],
         [{5,4},{5,4},{nil,nil},{5,4}],
         [{6,3},{5,4},{5,4},{nil,nil}]],
	?assertEqual([[2,4],[1,3]], vote_core:order(P)).