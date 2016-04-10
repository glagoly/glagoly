-module(create).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").

main() -> 
 	wf:wire(#api{name=create}),
	#dtl{file="create"}.

event(init) -> ok;
event(_) -> ok.

api_event(create, Response, _) ->
	wf:info(?MODULE,"Unknown Event: ~p~n",[Response]).