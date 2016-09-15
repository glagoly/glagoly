-module(matrix_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

new_test() ->
	?assertEqual(
		lists:sort(
			[{{a,a},0}, {{a,b},0},
		 	 {{b,a},0}, {{b,b},0}]), 
		lists:sort(matrix:to_list(matrix:new([a, b])))).
	