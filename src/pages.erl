-module(pages).

-export([init/2]).

init(Req0, State) ->
    Lang = cowboy_req:binding(lang, Req0),
    {ok, Body} = index_dtl:render([
        {title, Lang},
        {name, "Other"}
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
