-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

main() ->
	wf:info(?MODULE,"User: ~p~n",[wf:user()]),
	wf:wire(#api{name=fb_login}),
	#dtl{file="index", app=sample, bindings=[
		{fb_app_id, wf:config(glagoly, fb_app_id)},
		{create_button, #button{body="create poll",postback=create}},
		{login_button, #button{body="login",onclick="onLoginClick();"}},
		{logout_button, #button{body="logout",postback=logout}}
	]}.

event(logout) -> usr:logout();

event(create) -> 
	Id = polls:create(usr:ensure()),
	wf:redirect("/p?ll=" ++ wf:to_list(Id));

event(_) -> ok.

api_event(fb_login, Data, _) ->
	Token = jsone:decode(list_to_binary(Data)),
	usr:fb_login(Token).
