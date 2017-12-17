-module(routes).
-include_lib("n2o/include/wf.hrl").
-export([init/2, finish/2]).

finish(State, Ctx) -> {ok, State, Ctx}.
init(State, Ctx) ->
    Path = wf:path(Ctx#cx.req),
    Module = prefix(Path),
    wf:info(?MODULE,"Route: ~p~n",[Path]),
    {ok, State, Ctx#cx{path=Path,module=Module}}.

prefix(<<"/ws/",P/binary>>) -> route(P);
prefix(<<"/",P/binary>>)    -> route(P);
prefix(P)                   -> route(P).

route(<<>>)                 -> view_index;
route(<<"p">>)              -> view_poll;
route(_)                    -> view_404.
