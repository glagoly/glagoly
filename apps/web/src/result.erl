-module(result).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

main() ->
 	case kvs:get(poll, poll_id()) of
 		{ok, Poll} -> #dtl{file="results", bindings=[
			{title, wf:html_encode(Poll#poll.title)}
		]};
 		_ -> wf:state(status,404), "Poll not found" end.
