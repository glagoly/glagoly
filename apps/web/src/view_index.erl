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
		" in ",
		#link{href = "p?ll=" ++ Poll, body = #span{class=poll, body=P#poll.title}}
	]}.

my_body(User, Js_escape) -> [
	view_common:top_bar(),
	#dtl{file="my", js_escape=Js_escape, bindings=[ 
		{polls, #ul{ body = [poll(P#my_poll.user_poll) || P <- polls:my(User)]}}
	]}].

my(User) ->
	view_common:page([
		{title, "my polls"},
		{body, my_body(User, false)}
	]).

sample_buttons() -> [
		{sample_poll, #button{body="vote on sample decision", class=[button, primary], postback=sample_poll}}
	].

about() ->
	wf:wire(#api{name=fb_login}),
	view_common:page([
		{title, "schulze polls online"},
		{body, #dtl{file="index", app=sample, bindings=[ 
			{create_button, #button{body="create poll",postback=create}}
		] ++ sample_buttons()}}
	]).

main() ->
	case usr:id() of
		undefined -> about();
		User -> my(User)
	end.

event(sample_poll) ->
	Id = samples:create(poll),
	wf:redirect("/p?ll=" ++ wf:to_list(Id));

event(create) -> 
	Id = polls:create(usr:ensure()),
	wf:redirect("/p?ll=" ++ wf:to_list(Id)).

api_event(fb_login, Token, _) ->
	U = usr:fb_login(Token),
	view_common:wf_update(body, my_body(U, true)).
