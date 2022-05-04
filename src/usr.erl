-module(usr).
% usr because user is taken by erlang
-compile(export_all).

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
    nitro:user(
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
    Token2 = jsone:decode(list_to_binary(Token)),
    Url = nitro:to_list([
        "https://graph.facebook.com/v2.11/me",
        "?access_token=",
        Token2
    ]),
    {ok, {{_, 200, _}, _, Body}} = httpc:request(Url),
    Props = jsone:decode(list_to_binary(Body), [{object_format, proplist}]),
    Id = proplists:get_value(<<"id">>, Props),
    {_, U} = login({facebook, Id}),
    U.
