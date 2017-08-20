-module(edit).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

title(Poll) ->
	[#input{id=title, type=text, class= <<"title-input">>, placeholder=Poll#poll.title, value=Poll#poll.title}
	].
alts() ->
	[#li{class = <<"edit-form">>, body = [
		#panel{class = <<"vote-column">>, body=[]}
	]}].
%#####/*
%#;//			<li class="edit-form" id="alt-add">
%#/*			<div class="">#
%#				<input type="number" class="vote" min="-100" max="100" placeholder="&plusmn;7">
%			<%/div>
%			<div class="text-column">
%				<textarea class="text"></textarea>
%				<button class="button float-right" id="add-button">add alternative</button>
%			</div>
%		</li>

main() -> 
	case kvs:get(poll, poll_id()) of
		{ok, Poll} -> #dtl{file="edit", bindings=[{title, title(Poll)}, {alts, alts()}]};
		_ -> wf:state(status,404), "Poll not found" end.

event(_) -> ok.