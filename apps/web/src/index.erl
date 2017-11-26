-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

main() ->
	#dtl{file="index", app=sample, bindings=[
		{fb_app_id, wf:config(glagoly, fb_app_id)},
		{create_button, #button{body="create poll",postback=create} 
	}]}.

event(create) -> 
	Id = polls:create(usr:ensure()),
	wf:redirect("/edit?id=" ++ wf:to_list(Id));

event(_) -> ok.
