-module(create).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").

main() -> #dtl{file="create"}.

event(_) -> ok.
