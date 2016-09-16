-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").

main() -> 
	wf:info(?MODULE,"main loaded",[""]),
	#dtl{file="index", app=sample, bindings=[{create_button, #button{body="create poll",postback=create} }]}.

event(create) -> 
	wf:info(?MODULE,"create",[""]),
	Id = vote_core:uuid(),
	wf:redirect("/edit?id=" ++ wf:to_list(Id));

event(Event) -> wf:info(?MODULE,"Unknown Event: ~p~n",[Event]).
