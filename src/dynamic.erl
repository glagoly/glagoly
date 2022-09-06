-module(dynamic).

-export([init/2]).

init(Req0 = #{path := <<"/dynamic/poll.html">>}, State) ->
    #{id := Id} = cowboy_req:match_qs([id], Req0),
    {ok, Poll} = kvs:get(poll, nitro:to_list(Id)),
    {ok, Body} = poll_dtl:render([
        {title, polls:title(Poll)},
        {name, polls:name(Poll)}
    ]),
    Req = cowboy_req:reply(
        200,
        #{
            <<"content-type">> => <<"text/html">>
        },
        Body,
        Req0
    ),
    {ok, Req, State};
init(Req0, State) ->
    Req = cowboy_req:reply(404, #{}, "", Req0),
    {ok, Req, State}.
