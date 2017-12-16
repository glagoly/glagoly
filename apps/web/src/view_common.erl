-module(view_common).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").

wf_update(Target, Elements) ->
	Pid = self(),
	Ref = make_ref(),
	spawn(fun() -> R = wf:render(Elements), Pid ! {R, Ref, wf:actions()} end),
	{Render, Ref, Actions} = receive {_, Ref, _} = A -> A end,
	wf:wire(wf:f(
		"(function(){ qi('~s').outerHTML = '~s'; })();",
		[Target, Render])),
	wf:wire(wf:render(Actions)).

top_bar() ->
	#panel{class='top-bar', body=[
		#link{body="logout", delegate=view_common, postback=logout}
	]}.

bindings() -> [
		{fb_app_id, wf:config(web, fb_app_id)},
		{ga_id, wf:config(web, ga_id)}
	].

page(Bindings) -> 
	#dtl{file="_page", bindings=bindings() ++ Bindings}.

event(logout) ->
	usr:logout(),
	wf:redirect("/");

event(_) -> ok.
