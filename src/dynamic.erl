-module(dynamic).

-export([init/2]).

init(Req0=#{path := Path, qs := Qs}, State) ->
    io:fwrite("Hello world!~w", [Req0]),
    {ok, Body} =poll_dtl:render([]),
    Req = cowboy_req:reply(
        200,
        #{
            <<"content-type">> => <<"text/html">>
        },
        Body,
        Req0
    ),
    {ok, Req, State}.
