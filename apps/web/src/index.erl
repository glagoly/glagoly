-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

main() -> 
	#dtl{file="index", app=sample, bindings=[{create_button, #button{body="create poll",postback=create} }]}.

event(create) -> 
	Id = feed:create_poll(session:ensure_user()),
	wf:redirect("/edit?id=" ++ wf:to_list(Id));

event(_) -> ok.
