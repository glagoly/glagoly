-module(usr).
% usr because user is taken by erlang
-export([id/0, state/0, ensure/0, seed/0, fb_login/1, logout/0]).

-include_lib("records.hrl").

id() ->
    case n2o:user() of
        {_, U} -> U;
        _ -> guest
    end.

state() ->
    case n2o:user() of
        {State, _} -> State;
        _ -> guest
    end.

ensure() ->
    case id() of
        guest ->
            {_, Id} = n2o:user({temp, kvs:seq(user, 1)}),
            Id;
        Id ->
            Id
    end.

seed() -> erlang:binary_to_integer(n2o:sid(), 16).

logout() -> n2o:user(undefined).

login(Creds, Data) ->
    PersId =
        case kvs:get(login, Creds) of
            {ok, #login{user = UserId}} ->
                case n2o:user() of
                    {temp, TempId} -> polls:merge_user(UserId, TempId);
                    _ -> ok
                end,
                UserId;
            _ ->
                UserId = ensure(),
                kvs:put(#login{creds = Creds, user = UserId, data = Data}),
                UserId
        end,
    n2o:user({pers, PersId}).

fb_login(Token) ->
    Token2 = jsone:decode(list_to_binary(Token)),
    Url = ["https://graph.facebook.com/v13.0/me?access_token=", Token2],
    {ok, {{_, 200, _}, _, Body}} = httpc:request(nitro:to_list(Url)),
    Props = jsone:decode(list_to_binary(Body)),
    login({facebook, maps:get(<<"id">>, Props)}, Props).
