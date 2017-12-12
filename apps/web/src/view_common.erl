-module(view_common).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").

top_bar() ->
	#panel{class='top-bar', body=[
		#link{body="logout", delegate=view_common, postback=logout}
	]}.

bindings() -> [
		{fb_app_id, wf:config(web, fb_app_id)}
	].

page(Bindings) -> 
	#dtl{file="_page", bindings=bindings() ++ Bindings}.

event(logout) ->
	usr:logout(),
	wf:redirect("/");

event(_) -> ok.
