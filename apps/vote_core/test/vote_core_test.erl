-module(vote_core_test).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

init_test() ->
	D = [[nil, 1, 2],
		[3, nil, 4],
		[5, 6, nil]],
	P = [[{nil, nil}, {1, 3}, {2, 5}],
		[{3, 1}, {nil, nil}, {4, 6}],
		[{5, 2}, {6, 4}, {nil, nil}]],
	?assertEqual(P, vote_core:init(D)).

%% wikipedia sample
%% https://en.wikipedia.org/wiki/Schulze_method#Example
strongest_path_wiki_test() -> 
	D = [
			[00, 20, 26, 30, 22],
			[25, 00, 16, 33, 18],
			[19 ,29 ,00, 17, 24],
			[15 ,12 ,28, 00, 14],
			[23 ,27 ,21, 31, 00]
	],
	P = [
			[00, 28, 28, 30, 24],
			[25, 00, 28, 33, 24],
			[25, 29, 00, 29, 24],
			[25, 28, 28, 00, 24],
			[25, 28, 28, 31, 00]
	],
	?assertEqual(P, vote_core:strongest_path(D)).