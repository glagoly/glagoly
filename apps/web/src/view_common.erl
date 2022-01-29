-module(view_common).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("web.hrl").

ga_event(Category, Action) ->
	case wf:config(web, ga_id) of
		undefined -> no;
		_ -> wf:wire("ga('send', 'event', '" ++ wf:to_list(Category) ++
			"', '" ++  wf:to_list(Action) ++ "');")
	end.

wf_update(Target, Elements) ->
	Pid = self(),
	Ref = make_ref(),
	spawn(fun() -> R = wf:render(Elements), Pid ! {R, Ref, wf:actions()} end),
	{Render, Ref, Actions} = receive {_, Ref, _} = A -> A end,
	wf:wire(wf:f(
		"(function(){ qi('~s').outerHTML = '~s'; })();",
		[Target, Render])),
	wf:wire(wf:render(Actions)).

poll_button() -> poll_button([]).
poll_button(Class) -> 
	#button{body=?T("create poll"),class=Class,postback=create_poll, delegate=view_common}.

top_bar() ->
	#panel{class='navbar navbar-dark bg-primary', body=#panel{class=[container, main], body=[
		#link{href="/", class='navbar-brand ms-2', body=#image{
			src="/static/img/logo.svg", height=24, width=26, class="align-text-top ms-2"
		}},
		#panel{class='d-flex', body=[
			#button{
				body=?T("create"), class='btn btn-success',
				postback=create_poll, delegate=view_common},
			case usr:is_pers() of
				true -> #button{
					body=?T("logout"), class='btn btn-primary ms-2',
					delegate=view_common, postback=logout};
				_ -> ""
			end
		]}
	]}}.

bindings() -> [
		{fb_app_id, wf:config(web, fb_app_id)},
		{ga_id, wf:config(web, ga_id)}
	].

page(Bindings) ->
	wf:wire(#api{name=fb_login}),
	#dtl{file="_page", bindings=bindings() ++ Bindings}.

event(logout) ->
	usr:logout(),
	wf:redirect("/");

event(create_poll) ->
	Id = polls:create(usr:ensure()),
	wf:redirect("/p?ll=" ++ wf:to_list(Id));

event(_) -> ok.
