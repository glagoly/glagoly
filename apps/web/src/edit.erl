-module(edit).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

poll_alts() -> kvs:entries(kvs:get(feed, {poll, poll_id()}), alt, undefined).

alt(Alt, Vote) ->
	[#li{body=[
		#input{id="vote" ++ wf:to_list(Alt#alt.id), type=number, value=Vote, class=vote, min=-100, max=100, placeholder=0},
		#span{class=text, body=Alt#alt.text}
	]}].

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
		{alts, [alt(Alt, "") || Alt <- poll_alts()]},
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

prepare_prefs(Votes) -> 
	% to pairs of ints
	P1 = [{ filter:int(hd(tl(V)), -3, 7, 0), wf:to_integer(hd(V))} || V <- Votes],
	% remove not incorrect alt ids and zero prefs,
	Alts = [Alt#alt.id || Alt <- poll_alts()],
	lists:filter(fun({P, A}) -> (P /= 0) and lists:member(A, Alts) end, P1).

api_event(vote, Data, _) ->
	{Props} = jsone:decode(list_to_binary(Data)),
	Prefs = prepare_prefs(proplists:get_value(<<"votes">>, Props)),
	Name = filter:string(proplists:get_value(<<"name">>, Props), 32, <<"anon">>),
	Vote = #vote{id=kvs:next_id(vote, 1), feed_id={poll, poll_id()}, name=Name, prefs=some},
	kvs:add(Vote),
	wf:redirect("/result?id=" ++ wf:to_list(poll_id())).