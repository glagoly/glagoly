-module(view_index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").
-include_lib("web.hrl").

alt([]) -> <<"no vote">>;
alt([{A, _} | _]) -> 
	{ok, Alt} = kvs:get(alt, A), 
	wf:html_encode(Alt#alt.text).

poll({User, Poll}) ->
	{ok, P} = kvs:get(poll, Poll),
	V = polls:get_vote(User, Poll),
	#li{body = [
		#span{class=alt, body=alt(V#vote.ballot)},
		" in ",
		#link{href = "p?ll=" ++ Poll, body = #span{
			class=poll, body=wf:html_encode(P#poll.title)
		}}
	]}.

my_body(User, Js_escape) -> #panel{id=body, body=[
	view_common:top_bar(),
	#dtl{file="my", js_escape=Js_escape, bindings=[ 
		{polls, #ol{class=alts, body=[poll(P#my_poll.user_poll) || P <- polls:my(User)]}},
		{is_temp, not usr:is_pers()}
	]}]}.

my(User) ->
	view_common:page([
		{title, "my polls"},
		{body, my_body(User, false)}
	]).

sample_buttons() -> [
		{P,  #button{body=T, class=[button, primary], postback=P}} || {P, T} <- [
			{sample_poll, "vote on sample decision"},
			{sample_schedule, "vote on sample meeting schedule"},
			{sample_list, "vote on sample cocktail list"}
		]
	].

about() ->
	view_common:page([
		{title, "schulze polls online"},
		{description, "the fastest way to make micro-desicions, easy meeting schedule, fun rated lists"},
		{body, #dtl{file="index", app=sample, bindings=[ 
			{cta, [
				#h2{body = ?T("the fastest way <br /> to make micro-desicions")},
				view_common:poll_button()
			]},
			{create_button2, view_common:poll_button()}
		] ++ sample_buttons()}}
	]).

main() ->
	case usr:id() of
		undefined -> about();
		User -> my(User)
	end.

create_sample(Type) ->
	Id = samples:create(Type),
	wf:redirect("/p?ll=" ++ wf:to_list(Id)).

event(sample_poll) -> create_sample(poll);
event(sample_schedule) -> create_sample(schedule);
event(sample_list) -> create_sample(list).

api_event(fb_login, Token, _) ->
	U = usr:fb_login(Token),
	view_common:wf_update(body, my_body(U, true)).
