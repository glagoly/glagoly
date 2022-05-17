-module(usr).
% usr because user is taken by erlang
-export([id/0, is_pers/0, ensure/0, seed/0, fb_login/1, logout/0]).

-include_lib("n2o/include/n2o.hrl").
-include_lib("records.hrl").

id() ->
    case n2o:user() of
        {_, U} -> U;
        _ -> undefined
    end.

is_pers() ->
    case n2o:user() of
        {pers, _} -> true;
        _ -> false
    end.

ensure() ->
    case n2o:user() of
        {_, U} ->
            U;
        _ ->
            U = kvs:seq(user, 1),
            n2o:user({temp, U}),
            U
    end.

seed() -> erlang:binary_to_integer(n2o:sid(), 16).

logout() -> nitro:user(undefined).

login({_, undefined}) ->
    no;
login(Creds) ->
    n2o:user(
        {pers,
            case kvs:get(login, Creds) of
                {ok, #login{user = U}} ->
                    polls:merge_user(U, id()),
                    U;
                _ ->
                    U = ensure(),
                    kvs:put(#login{creds = Creds, user = U}),
                    U
            end}
    ).

fb_login(Token) ->
    io:format("Token: ~p~n", [Token]),
    Token2 = jsone:decode(list_to_binary(Token)),
    io:format("Token: ~p~n", [Token2]),
    ?LOG_INFO({Token2}),
    Url = ["https://graph.facebook.com/v13.0/me?access_token=", Token2],
    {ok, {{_, 200, _}, _, Body}} = httpc:request(nitro:to_list(Url)),
    Props = jsone:decode(list_to_binary(Body)),
    io:format("Props: ~p~n", [Props]),
    {_, U} = login({facebook, maps:get(<<"id">>, Props)}),
    U.
