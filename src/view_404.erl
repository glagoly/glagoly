-module(view_404).
-compile(export_all).
-include_lib("n2o/include/n2o.hrl").
-include_lib("nitro/include/nitro.hrl").

main() ->
    nitro:state(status, 404),
    #h1{body = "Page not found"}.

event(_) -> ok.
