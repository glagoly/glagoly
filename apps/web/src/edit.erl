-module(edit).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

poll() ->
	case kvs:get(poll, poll_id()) of
		{ok, Poll} -> Poll;
		_ -> undefined
	end.

poll_alts() -> kvs:entries(kvs:get(feed, {alts, poll_id()}), alt, undefined).

author(I, _, I) -> <<"<i>I</i>">>;
author(User, Poll, _) ->
	case polls:get_vote(User, Poll) of
		#vote{name = []} -> <<"anonymous">>;
		#vote{name = Name} -> Name
	end.

alt(Alt, Vote) ->
	[#li{body=[
		#input{id="vote" ++ wf:to_list(Alt#alt.id), type=number, value=Vote, class=vote, min=-100, max=100, placeholder=0},
		#span{class=text, body=Alt#alt.text},
		#span{class=author, body=author(Alt#alt.user, poll_id(), wf:user())}
	]}].

alt_form() ->
	[#panel{class='vote-column', body=[
		#input{id=alt_vote, type=number, class=vote, min=-100, max=100, placeholder=0}
	]}, #panel{class='text-column', body=[
		#textarea{id=alt_text, class=text},
		#button{id=send, class=[button, 'float-right'], body="add alternative", 
				postback=add_alt, source=[alt_vote, alt_text]}
	]}].

title(#poll{user=User, title=Title})->
	case wf:user() of
		User -> #textbox{id=title, maxlength=20, 
			class='title-input', placeholder=Title, value=Title};
		_ -> #h1{body = Title}
	end.

update_title(Poll, Title) ->
	User = wf:user(),
	case Poll#poll.user of
		 User -> kvs:put(Poll#poll{title = Title});
		_ -> ok
	end.

alts(Alts, undefined) -> alts(Alts, #vote{ballot = []});
alts(Alts, #vote{ballot = Ballot}) ->
	[alt(Alt, wf:to_list(V)) || {V, P, Alt} <- polls:user_alts(Alts, Ballot, session:seed())].

edit_page(Poll)->
	wf:wire(#api{name=vote}),
	Vote = polls:get_vote(wf:user(), poll_id()),
	#dtl{file="edit", bindings=[
		{title, title(Poll)},
		{alts, alts(poll_alts(), Vote)},
		{alt_form, alt_form()},
		{name, Vote#vote.name}
	]}.

main() ->
	case poll() of
		undefined -> wf:state(status,404), "Poll not found";
		Poll -> edit_page(Poll)
	end.

event(add_alt) ->
	Alt = #alt{id=kvs:next_id(alt, 1), user=session:ensure_user(), feed_id={alts, poll_id()}, text=wf:q(alt_text)},
	kvs:add(Alt),
	wf:insert_bottom(alts, alt(Alt, wf:q(alt_vote)));

event(_) -> ok.

prepare_prefs(Votes) -> 
	% to pairs of ints
	P1 = [{ wf:to_integer(A), filter:int(V, -3, 7, 0)} || [A, V] <- Votes],
	% remove not incorrect alt ids and zero prefs,
	Alts = [Alt#alt.id || Alt <- poll_alts()],
	lists:filter(fun({A, V}) -> (V /= 0) and lists:member(A, Alts) end, P1).

api_event(vote, Data, _) ->
	{Props} = jsone:decode(list_to_binary(Data)),
	User = session:ensure_user(),
	Prefs = prepare_prefs(proplists:get_value(<<"votes">>, Props, [])),
	Name = filter:string(proplists:get_value(<<"name">>, Props, []), 32, <<"anon">>),
	Title = filter:string(proplists:get_value(<<"title">>, Props, []), 32, <<"poll">>),
	update_title(poll(), Title),
	polls:put_vote(User, poll_id(), Name, Prefs),
	wf:redirect("/result?id=" ++ wf:to_list(poll_id())).