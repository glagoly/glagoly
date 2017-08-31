-module(edit).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

alt(Alt, Vote) ->
	[#li{body=[
		#input{id="vote" ++ wf:to_list(Alt#alt.id), type=number, value=Vote, class=vote, min=-100, max=100, placeholder=0},
		#span{class=text, body=Alt#alt.text}
	]}].

alts() -> 
	[alt(Alt, "") || Alt <- kvs:entries(kvs:get(feed, {poll, poll_id()}), alt, undefined)].

alt_form() ->
	[#panel{class='vote-column', body=[
		#input{id=alt_vote, type=number, class=vote, min=-100, max=100, placeholder=0}
	]}, #panel{class='text-column', body=[
		#textarea{id=alt_text, class=text},
		#button{id=send, class=[button, 'float-right'], body="add alternative", 
				postback=add_alt, source=[alt_vote, alt_text]}
	]}].

vote_page()->
	wf:wire(#api{name=vote}),
	#dtl{file="edit", bindings=[
		{alts, alts()},
		{alt_form, alt_form()}
	]}.

main() ->
	case kvs:get(poll, poll_id()) of
		{ok, Poll} -> vote_page();
		_ -> wf:state(status,404), "Poll not found" end.

event(add_alt) ->
	Alt = #alt{id=kvs:next_id(alt, 1), feed_id={poll, poll_id()}, text=wf:q(alt_text)},
	kvs:add(Alt),
	wf:insert_bottom(alts, alt(Alt, wf:q(alt_vote)));

event(_) -> ok.

api_event(vote, Data, _) ->
	{Props} = jsone:decode(list_to_binary(Data)),
	wf:info(?MODULE,"Props: ~p~n",[Props]).