-module(routes).

-include_lib("n2o/include/n2o.hrl").

-export([init/2, finish/2]).


finish(State, Ctx) -> {ok, State, Ctx}.

init(State, #cx{req = Req} = Cx) ->
    #{path := Path} = Req,
    {ok,
     State,
     Cx#cx{path = Path, module = route_prefix(Path)}}.

route_prefix(<<"/ws/", P/binary>>) -> route(P);
route_prefix(<<"/", P/binary>>) -> route(P);
route_prefix(P) -> route(P).

% Routes

route(<<>>) -> view_index;
route(<<"policy">>) -> view_policy;

route(<<"p">>) -> view_poll;
% 7 char poll ID
route(<<Id:(7*8)>>) -> view_poll;
% 22 char poll ID (legacy)
route(<<Id:(22*8)>>) -> view_poll;

route(_) -> view_404.
