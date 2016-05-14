-module(poll).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_integer(wf:q(<<"id">>)).

main() -> 
	wf:info(?MODULE,"Unknown Event: ~p~n",[kvs:get(poll, poll_id())]),
	case kvs:get(poll, poll_id()) of
		{ok, Poll} -> #dtl{file="results", bindings=[
			{title, wf:html_encode(Poll#poll.title)}]};
		_ -> wf:state(status,404), "Post not found" end.

event(_) -> ok.