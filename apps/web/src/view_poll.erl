-module(view_poll).
-export([main/0, event/1, api_event/3]).

-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").
-include_lib("web.hrl").

-define(ALT_ID(A), "alt" ++ wf:to_list(A#alt.id)).

-define(TITLE_MAX_LENGTH, 64).


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
		#vote{name = Name} -> wf:html_encode(Name)
	end.

vote_input(Id, Value) ->
	"<input class=form-range id=" ++ Id ++ " name=" ++ Id ++
	" value=" ++ wf:to_list(Value) ++
	" type=range min=-3 max=7 oninput=\"onSliderChange(this)\">".

alt_link(Postback, Body, Alt) -> alt_link(Postback, Body, Alt, []).
alt_link(Postback, Body, Alt, Source) ->
	#link{
		id=wf:to_list([Postback, Alt#alt.id]),
		body=Body,
		class=Postback,
		postback=Postback,
		source=[{id, wf:to_list(["number(", Alt#alt.id, ")"])}] ++ Source
	}.

restore_alt(Alt) -> [#li{id = ?ALT_ID(Alt), class=deleted, body=[
		alt_link(restore_alt, "Restore", Alt), " deleted alterntive"
	]}].

alt_text(Alt, Edit) -> [
	#panel{id=?ALT_ID(Alt) ++ "text", body = [
		case Edit of
			true -> #span{class=buttons, body = [
				alt_link(del_alt, "delete", Alt),
				alt_link(edit_alt, "edit", Alt)
			]};
			_ -> []
		end,
		#panel{class=inner, body = [
			#span{body=[]},
			#span{class=author, body=author(Alt#alt.user, poll_id(), usr:id())}
		]}
	]}].

alt_header() -> [].

alt_body(Alt) -> 
	#panel{class='card-body', body=#p{class='card-text',body=[
		wf:html_encode(Alt#alt.text)
	]}}.

alt_footer(Alt, Id, Vote) ->
	#panel{class='card-footer', body=#panel{class='row align-items-center', body=[
		#panel{class='col-2', body=[
			#h4{class='text-center mb-0',
				body=#span{
					id=Id ++ "text", class='badge bg-secondary', body=pos_format(Vote)}}
		]},
		#panel{class='col-10 small', body=vote_input(Id, Vote)}
	]}}.

alt(Alt, Vote, Edit) ->
	Id = "vote" ++ wf:to_list(Alt#alt.id),
	#panel{id = ?ALT_ID(Alt), class='card mb-3', body=[
		alt_body(Alt),
		alt_footer(Alt, Id, Vote)
	]}.

alt_form() ->
	#panel{class='card mb-3', body=[
		#panel{class='card-header', body=?T("Add my alternative")},
		#panel{class='card-body', body=#textarea{
			id=alt_text, maxlength=128, class='form-control', rows=3}},
		#panel{class='card-footer text-end', body=#button{
			id=send, class='btn btn-primary btn-sm', body=?T("Add"),
			postback=add_alt, source=[alt_text]}}
	]}.

title(User, Poll)->
	T = wf:html_encode(Poll#poll.title),
	case can_edit(User, Poll) of
		true -> #textbox{id=title, maxlength=?TITLE_MAX_LENGTH, class='title-input', placeholder=T, value=T};
		_ -> #h1{body=T, class='display-5 mb-3 mt-3'}
	end.

update_title(Poll, Title) ->
	User = usr:id(),
	case Poll#poll.user of
		 User -> kvs:put(Poll#poll{title = Title});
		_ -> ok
	end.

alts(User, Poll, Alts, #vote{ballot = Ballot}) ->
	Alts2 = polls:user_alts(Alts, Ballot, usr:seed()),
	[alt(Alt, V, can_edit(User, Poll, Alt)) || {V, P, Alt} <- Alts2].

manual(true) ->
	#ol{body=[
		#li{body=?T("add most preferable alternative and rate it with &#xFF0B;7")},
		#li{body=?T("add some less preferable alternatives and rate them with &#xFF0B;5, &#xFF0B;3, &#xFF0B;1")},
		#li{body=?T("add other alternatives and leave them without rating")}
	]};

manual(_) ->
	#ol{body=[
		#li{body=?T("add or rate the most preferable alternative with &#xFF0B;7")},
		#li{body=?T("rate less preferable alternatives with &#xFF0B;5, &#xFF0B;3, &#xFF0B;1")},
		#li{body=?T("rate unacceptable alternative with &#65293;3")}
	]}.

vote_form(Name, Alts) ->
	#panel{class='mt-4', body=[
		#label{class='form-label', body=[
			?T("Your name"), " ", #small{body=?T("(required)")}]},
		#element{
			html_tag=input, id=name, class='form-control',
			data_fields=[
				{type, "text"}, {maxlength, 32},
				{value, wf:html_encode(Name)}, {onchange, 'validateName()'}]},
		#panel{class='d-grid gap-2 mt-4',body=case Alts of
			[] -> #submit{class='btn btn-success', body=?T("Create poll")};
			_ -> [
				#submit{class='btn btn-success', body=?T("Vote")},
				#button{class='btn btn-outline-secondary', 
					body=?T("View results"), postback=view_results}
			] end}
	]}.

edit_panel(Poll, Vote, Alts, Js_escape) ->
	wf:wire(#api{name=vote}),
	User = usr:id(),
	#dtl{file="edit", js_escape=Js_escape, bindings=[
		{title_input, title(User, Poll)},
		{alts, alts(User, Poll, Alts, Vote)},
		{alt_form, alt_form()},
		{vote_form, vote_form(Vote#vote.name, Alts)},
		{manual, manual(Alts == [])}
	]}.

name_list(L) ->
	I = usr:id(),
	L2 = lists:map(fun
		({U, _, P}) when U == I -> {"<i>I</i>" ++ pos_format(P) ++ "", P};
		({_, N, P}) -> {wf:hte(wf:to_list(N)) ++ "" ++ pos_format(P), P}
	end, L),
	L3 = lists:map(fun
		({S, P}) when P > 0 -> "<span class='upwote'>" ++ S ++"</span>";
		({S, _}) -> S
	end, L2),
	string:join(L3, ", ").

pos_format(P) when P > 0 -> "&#65291;" ++ wf:to_list(P);
pos_format(P) when P == 0 -> "&empty;";
pos_format(P) -> "&mdash;" ++ wf:to_list(-P).

li_class(Pos) when Pos < 1 -> looser;
li_class(_) -> upwoted.

sups([]) -> "";
sups(S) -> #span{class=supps, body=name_list(S)}.

result(Ids, Pos, Supps, Classes) ->
	Alts = [kvs:get(alt, Id) || Id <- Ids],
	R =[#li{class=Classes ++ [li_class(Pos)] ,body=[
		#span{class=vote, body=pos_format(Pos)},
		#panel{class=text, body=[
			wf:hte(Alt#alt.text),
			sups(dict:fetch(Alt#alt.id, Supps))
		]}
	]} || {ok, Alt} <- Alts].

results([]) -> [];
results([{Winners, Pw} | Other]) ->
	Supps = polls:supporters(poll_id()),
	O = [result(Ids, P, Supps, []) || {Ids, P} <- Other],
	result(Winners, Pw, Supps, [winner]) ++ O.

results() -> results(polls:result(poll_id())).

results_panel(Poll, Js_escape) ->
	#dtl{file="results", js_escape=Js_escape, bindings=[
		{title, wf:html_encode(Poll#poll.title)},
		{results, results()},
		{poll_id, poll_id()},
		{vote_button, #button{id=send, class=[button], body="change vote", postback=show_edit}},
		{is_temp, not usr:is_pers()}
	]}.

poll_body(Poll, Alts, Js_escape)->
	Vote = polls:get_vote(usr:id(), poll_id()),
	#panel{id=body, body=[
		view_common:top_bar(),
		case Vote#vote.ballot of
			[] -> edit_panel(Poll, Vote, Alts, Js_escape);
			_ -> results_panel(Poll, Js_escape)
		end
	]}.

main() ->
	% attemt to localise, return t it later
	% {ok, L, _} = cowboy_req:parse_header(<<"accept-language">>, ?REQ, <<"en">>),
	% io:fwrite("H~s", [wf:to_list(L)]),
	case poll() of
		undefined -> view_404:main();
		Poll -> 
			Alts = polls:alts(Poll#poll.id),
			Desc = string:join([wf:to_list(A#alt.text) || A <- Alts], ", "),
			view_common:page([
				{title, wf:html_encode(Poll#poll.title)},
				{description, wf:html_encode(Desc)},
				{body, poll_body(Poll, Alts, false)}
			])
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

add_alt(Text) ->
	case filter:string(Text, 128, []) of
	 	[] -> no; 
	 	T -> 
	 		Alt = #alt{id=kvs:next_id(alt, 1), user=usr:ensure(), feed_id={alts, poll_id()}, text=T},
			kvs:add(Alt),
			Alt
	 end.

event(add_alt) ->
	case add_alt(wf:q(alt_text)) of
		no -> no;
		Alt ->
			wf:insert_bottom(alts, alt(Alt, 0, true)),
			wf:wire("clearAltForm();")
	end;

event(del_alt) -> 
	alt_event(fun (Poll, Alt) ->
		kvs:put(Alt#alt{hidden = true}),
		view_common:wf_update(?ALT_ID(Alt), restore_alt(Alt))
	end);

event(edit_alt) ->
	alt_event(fun (Poll, Alt) ->
		Id = ?ALT_ID(Alt) ++ "text",
		view_common:wf_update(Id, #panel{id=Id, body = [
			#textarea{id=?ALT_ID(Alt) ++ "new", maxlength=128, body=wf:hte(Alt#alt.text)},
			#panel{class=edit_buttons, body = [
				alt_link(cancel_edit_alt, "cancel", Alt),
				alt_link(update_alt, "save", Alt, [?ALT_ID(Alt) ++ "new"])
			]}
		]})
	end);

event(cancel_edit_alt) ->
	alt_event(fun (Poll, Alt) ->
		view_common:wf_update(?ALT_ID(Alt) ++ "text", alt_text(Alt, true))
	end);

event(update_alt) ->
	alt_event(fun (Poll, Alt) ->
		Text = filter:string(wf:q(?ALT_ID(Alt) ++ "new"), 128, []),
		case Text of
	 		[] -> no; 
	 		T -> 
				New = Alt#alt{user=usr:id(), text=T},
				kvs:put(New),
				view_common:wf_update(?ALT_ID(Alt) ++ "text", alt_text(New, true))
		end
	end);

event(restore_alt) ->
	alt_event(fun (Poll, Alt) ->
		kvs:put(Alt#alt{hidden = false}),
		V = polls:get_vote(usr:id(), poll_id()),
		B = maps:from_list(V#vote.ballot),
		view_common:wf_update(?ALT_ID(Alt), alt(Alt, maps:get(Alt#alt.id, B, 0), true))
	end);

event(show_edit) ->
	Poll = poll(),
	Alts = polls:alts(Poll#poll.id),
	Vote = polls:get_vote(usr:id(), poll_id()),
	view_common:wf_update(results_panel, edit_panel(Poll, Vote, Alts, true));

event(view_results) ->
	view_common:wf_update(edit_panel, results_panel(poll(), true)),
	wf:wire("FB.XFBML.parse();");

event(_) -> ok.

prepare_prefs(Votes) -> 
	% to pairs of ints
	wf:warning(Votes),
	P1 = [{ wf:to_integer(A), filter:int(V, -3, 7, 0)} || [A, V] <- Votes],
	% remove not incorrect alt ids and zero prefs,
	Alts = polls:alt_ids(poll_id()),
	P2 = lists:filter(fun({A, V}) -> (V /= 0) and lists:member(A, Alts) end, P1),
	lists:reverse(lists:keysort(2, P2)).

api_event(fb_login, Token, _) ->
	U = usr:fb_login(Token),
	Poll = poll(),
	Alts = polls:alts(Poll#poll.id),
	view_common:wf_update(body, poll_body(Poll, Alts, true));

api_event(vote, Data, _) ->
	Props = jsone:decode(list_to_binary(Data), [{object_format, proplist}]),

	Title = filter:string(get_value(<<"title">>, Props), ?TITLE_MAX_LENGTH, <<"poll">>),
	update_title(poll(), Title),

	NewVotes = case add_alt(get_value(<<"alt_text">>, Props)) of
		no -> [];
		Alt -> [[Alt#alt.id, 0]]
	end,
	Prefs = prepare_prefs(get_value(<<"votes">>, Props) ++ NewVotes),

	User = usr:ensure(),
	Name = filter:string(get_value(<<"name">>, Props), 32, <<"anon">>),
	polls:put_vote(User, poll_id(), Name, Prefs),
	event(view_results),
	view_common:ga_event(poll, vote).

get_value(Key, Props) -> proplists:get_value(Key, Props, []).