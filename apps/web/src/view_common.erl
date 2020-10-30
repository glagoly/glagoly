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
	#panel{class='top-bar', id='top-bar', body=#panel{class=[row, columns], body=[
		#panel{class='top-bar-left', body = #ul{
			class=menu, body=#li{class='menu-text', body=#link{
				href="/", body=[#image{
					class=logo,	src="/static/img/logo-light.svg"
				}]
			}}}
		},
		#panel{class='top-bar-right', body = #ul{
			class=menu, body=[
			#li{body=poll_button([button,main])},
			#li{class='top-login', body=case usr:is_pers() of
				true -> #link{body=?T("logout"), delegate=view_common, postback=logout};
				_ -> ""
			end}
		]}}
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
