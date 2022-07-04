-module(filter_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

in_range_test() ->
    ?assertEqual(0, filter:in_range(0, 0, 5)),
    ?assertEqual(5, filter:in_range(9, 0, 5)).

string_test() ->
    ?assertEqual(<<"тес"/utf8>>, filter:string(<<"тест"/utf8>>, 3, "")),
    ?assertEqual(<<"тест"/utf8>>, filter:string(<<194, 160, " тест"/utf8>>, 4, "")),
    ?assertEqual(<<"тест"/utf8>>, filter:string(<<" "/utf8>>, 4, <<"тест"/utf8>>)).
