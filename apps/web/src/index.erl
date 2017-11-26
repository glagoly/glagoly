-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

main() ->
	wf:wire(#api{name=fb_login}),
	#dtl{file="index", app=sample, bindings=[
		{fb_app_id, wf:config(glagoly, fb_app_id)},
		{create_button, #button{body="create poll",postback=create}},
		{login_button, #button{body="login",onclick="onLoginClick();"}}
	]}.

event(create) -> 
	Id = polls:create(usr:ensure()),
	wf:redirect("/edit?id=" ++ wf:to_list(Id));

event(_) -> ok.

api_event(fb_login, Data, _) ->
	Token = jsone:decode(list_to_binary(Data)),
	wf:info(?MODULE,"Token: ~p~n",[Token]).

