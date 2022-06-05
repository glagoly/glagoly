-module(filter_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

int_test() ->
    ?assertEqual(0, vote_core:int(undefined, -10, 10, 0)),
    ?assertEqual(10, vote_core:int(<<"100">>, -10, 10, 0)),
    ?assertEqual(5, vote_core:int(<<"5">>, -10, 10, 0)).

string_test() ->
    ?assertEqual(<<"тес"/utf8>>, filter:string(<<"тест"/utf8>>, 3, "")),
    ?assertEqual(<<"тест"/utf8>>, filter:string(<<" тест"/utf8>>, 4, "")),
    ?assertEqual(<<"тест"/utf8>>, filter:string(<<" "/utf8>>, 4, <<"тест"/utf8>>)).
