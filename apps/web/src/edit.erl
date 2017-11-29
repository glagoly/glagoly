-module(edit).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

-define(ALT_ID(A), "alt" ++ wf:to_list(A#alt.id)).

poll_id() -> wf:to_list(wf:q(<<"ll">>)).

poll() ->
	case kvs:get(poll, poll_id()) of
		{ok, Poll} -> Poll;
		_ -> undefined
	end.

can_edit(User, #poll{user = U}) -> U == User.
can_edit(User, Poll, #alt{user = U}) -> can_edit(User, Poll) or (U == User).

author(I, _, I) -> <<"<i>I</i>">>;
author(User, Poll, _) ->
	case polls:get_vote(User, Poll) of
		#vote{name = []} -> <<"anonymous">>;
		#vote{name = Name} -> Name
	end.

vote_input(Id, <<"0">>) -> vote_input(Id, []);
vote_input(Id, "0") -> vote_input(Id, []);

vote_input(Id, Value) ->
	#input{id=Id, name=Id, type=number, value=Value, class=vote, min=-3, max=7, placeholder=0}.

alt_link(Postback, Body, Alt) -> alt_link(Postback, Body, Alt, []).
alt_link(Postback, Body, Alt, Source) ->
	#link{
		id=wf:to_list([Postback, Alt#alt.id]),
		body=Body,
		postback=Postback,
		source=[{id, wf:to_list(["number(", Alt#alt.id, ")"])}] ++ Source
	}.

restore_alt(Alt) -> [#li{id = ?ALT_ID(Alt), body=[
		alt_link(restore_alt, "Restore", Alt), " deleted alterntive"
	]}].

alt_text(Alt, Edit) ->
	#span{id=?ALT_ID(Alt) ++ "text", body = [
		#span{class=text, body=Alt#alt.text},
		#span{class=author, body=author(Alt#alt.user, poll_id(), usr:id())},
		case Edit of
			true -> #span{class=buttons, body = [
				alt_link(del_alt, "delete", Alt),
				alt_link(edit_alt, "edit", Alt)
			]};
			_ -> []
		end
	]}.

alt(Alt, Vote, Edit) ->
	[#li{id = ?ALT_ID(Alt), body=[
		vote_input("vote" ++ wf:to_list(Alt#alt.id), Vote),
		alt_text(Alt, Edit)
	]}].

alt_form() ->
	[#panel{class='vote-column', body=[
		vote_input(alt_vote, [])
	]}, #panel{class='text-column', body=[
		#textarea{id=alt_text, class=text},
		#button{id=send, class=[button, 'float-right'], body="add alternative", 
				postback=add_alt, source=[alt_vote, alt_text]}
	]}].

title(User, Poll)->
	case can_edit(User, Poll) of
		true -> #textbox{id=title, maxlength=20, 
			class='title-input', placeholder=Poll#poll.title, value=Poll#poll.title};
		_ -> #h1{body = Poll#poll.title}
	end.

update_title(Poll, Title) ->
	User = usr:id(),
	case Poll#poll.user of
		 User -> kvs:put(Poll#poll{title = Title});
		_ -> ok
	end.

alts(User, Poll, #vote{ballot = Ballot}) ->
	Alts = polls:user_alts(polls:alts(Poll#poll.id), Ballot, usr:seed()),
	[alt(Alt, wf:to_list(V), can_edit(User, Poll, Alt)) || {V, P, Alt} <- Alts].

edit_page(Poll)->
	wf:wire(#api{name=vote}),
	User = usr:id(),
	Vote = polls:get_vote(User, poll_id()),
	#dtl{file="edit", bindings=[
		{title, title(User, Poll)},
		{alts, alts(User, Poll, Vote)},
		{alt_form, alt_form()},
		{name, Vote#vote.name}
	]}.

main() ->
	case poll() of
		undefined -> wf:state(status,404), "Poll not found";
		Poll -> edit_page(Poll)
	end.

alt_event(Fun) -> 
	Poll = poll(),
	AltId = wf:to_integer(wf:q(id)),
	case polls:get_alt(Poll, AltId) of
		undefined -> no;
		Alt -> case can_edit(usr:id(), Poll, Alt) of
			true -> Fun(Poll, Alt);
			_ -> no
		end
	end.

event(add_alt) ->
	Alt = #alt{id=kvs:next_id(alt, 1), user=usr:ensure(), feed_id={alts, poll_id()}, text=wf:q(alt_text)},
	kvs:add(Alt),
	wf:insert_bottom(alts, alt(Alt, wf:q(alt_vote), true));

event(del_alt) -> 
	alt_event(fun (Poll, Alt) ->
		kvs:put(Alt#alt{hidden = true}),
		wf:update(?ALT_ID(Alt), restore_alt(Alt))
	end);

event(edit_alt) ->
	alt_event(fun (Poll, Alt) ->
		Id = ?ALT_ID(Alt) ++ "text",
		wf:update(Id, #panel{id=Id, body = [
			#textarea{id=?ALT_ID(Alt) ++ "new", body=Alt#alt.text},
			alt_link(cancel_edit_alt, "cancel", Alt),
			alt_link(update_alt, "save", Alt, [?ALT_ID(Alt) ++ "new"])
		]})
	end);

event(cancel_edit_alt) ->
	alt_event(fun (Poll, Alt) ->
		wf:update(?ALT_ID(Alt) ++ "text", alt_text(Alt, true))
	end);

event(update_alt) ->
	alt_event(fun (Poll, Alt) ->
		New = Alt#alt{user=usr:id(), text=wf:q(?ALT_ID(Alt) ++ "new")},
		kvs:put(New),
		wf:update(?ALT_ID(Alt) ++ "text", alt_text(New, true))
	end);

event(restore_alt) ->
	alt_event(fun (Poll, Alt) ->
		kvs:put(Alt#alt{hidden = false}),
		V = polls:get_vote(usr:id(), poll_id()),
		B = maps:from_list(V#vote.ballot),
		wf:update(?ALT_ID(Alt), alt(Alt, wf:to_list(maps:get(Alt#alt.id, B, 0)), true))
	end);

event(_) -> ok.

prepare_prefs(Votes) -> 
	% to pairs of ints
	P1 = [{ wf:to_integer(A), filter:int(V, -3, 7, 0)} || [A, V] <- Votes],
	% remove not incorrect alt ids and zero prefs,
	Alts = polls:alt_ids(poll_id()),
	P2 = lists:filter(fun({A, V}) -> (V /= 0) and lists:member(A, Alts) end, P1),
	lists:keysort(2, P2).

api_event(vote, Data, _) ->
	Props = jsone:decode(list_to_binary(Data), [{object_format, proplist}]),
	User = usr:ensure(),
	Prefs = prepare_prefs(proplists:get_value(<<"votes">>, Props, [])),
	Name = filter:string(proplists:get_value(<<"name">>, Props, []), 32, <<"anon">>),
	Title = filter:string(proplists:get_value(<<"title">>, Props, []), 32, <<"poll">>),
	update_title(poll(), Title),
	polls:put_vote(User, poll_id(), Name, Prefs),
	wf:redirect("/result?id=" ++ wf:to_list(poll_id())).