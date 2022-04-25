-module(routes).

-include_lib("n2o/include/n2o.hrl").

-export([init/2, finish/2]).

finish(State, Ctx) -> {ok, State, Ctx}.

init(State, #cx{req = Req} = Cx) ->
    #{path := Path} = Req,
    {ok, State, Cx#cx{path = Path, module = route_prefix(Path)}}.

route_prefix(<<"/ws/", P/binary>>) -> route(P);
route_prefix(<<"/", P/binary>>) -> route(P);
route_prefix(P) -> route(P).

% Routes

route(<<"app/", R/binary>>) -> route(R);

route(<<"index.html">>) -> view_index;
route(<<"poll.html">>) -> view_poll;
route(<<"feed.html">>) -> view_index.
