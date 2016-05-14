-module(filter_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").


right_test() ->
	?assertEqual(<<"тес"/utf8>>, filter:string(<<"тест"/utf8>>, 3, "")),
	?assertEqual(<<"тест"/utf8>>, filter:string(<<" тест"/utf8>>, 4, "")),
	?assertEqual(<<"тест"/utf8>>, filter:string(<<" "/utf8>>, 4, <<"тест"/utf8>>)).