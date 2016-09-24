-module(edit).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

body(Poll) ->
	[#input{id=title, type=text, class= <<"title-input">>, placeholder=Poll#poll.title, value=Poll#poll.title}
	].

main() -> 
	case kvs:get(poll, poll_id()) of
		{ok, Poll} -> #dtl{file="edit", bindings=[{vote_body, body(Poll)}]};
		_ -> wf:state(status,404), "Poll not found" end.

event(_) -> ok.