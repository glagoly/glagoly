-module(view_index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

alt([]) -> <<"No vote">>;
alt([{A, _} | _]) -> {ok, Alt} = kvs:get(alt, A), Alt#alt.text.

poll({User, Poll}) ->
	{ok, P} = kvs:get(poll, Poll),
	V = polls:get_vote(User, Poll),
	#li{body = [
		#span{class=alt, body=alt(V#vote.ballot)},
		<<" in ">>,
		#link{href = "p?ll=" ++ Poll, body = #span{class=poll, body=P#poll.title}}
	]}.


my(User) ->
	view_common:page([
		{title, "my polls"},
		{body, #dtl{file="my", app=sample, bindings=[ 
			{polls, [poll(P#my_poll.user_poll) || P <- polls:my(User)]}
		]}}
	]).

about() ->
	wf:wire(#api{name=fb_login}),
	view_common:page([
		{title, "schulze polls online"},
		{body, #dtl{file="index", app=sample, bindings=[ 
			{create_button, #button{body="create poll",postback=create}},
			{login_button, #button{body="login",onclick="onLoginClick();"}},
			{logout_button, #button{body="logout",postback=logout}}
		]}}
	]).

main() ->
	wf:info(?MODULE,"User: ~p",[usr:id()]),
	case usr:id() of
		undefined -> about();
		User -> my(User)
	end.

event(logout) -> usr:logout();

event(create) -> 
	Id = polls:create(usr:ensure()),
	wf:redirect("/p?ll=" ++ wf:to_list(Id));

event(_) -> ok.

api_event(fb_login, Data, _) ->
	Token = jsone:decode(list_to_binary(Data)),
	usr:fb_login(Token).
