-module(view_common).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").


bindings() -> [
		{fb_app_id, wf:config(glagoly, fb_app_id)}
	].

page(Bindings) -> 
	#dtl{file="_page", bindings=bindings() ++ Bindings}.
