-module(create).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

main() -> 
 	wf:wire(#api{name=create}),
	#dtl{file="create"}.

event(_) -> ok.

update_alternative(PollId, Id, Text, true, _) ->
	kvs:add(#alternative{
		id=kvs:next_id(alternative, 1),
		feed_id={poll, PollId}, 
		text=Text}).

update_alternative(PollId, Id, Props) ->
	update_alternative(
		PollId,
		Id,
		filter:string(proplists:get_value(<<"text">>, Props), 128, undefined),
		proplists:get_value(<<"new">>, Props),
		proplists:get_value(<<"deleted">>, Props)
	).

update_alternatives(PollId, {Changes}) ->
	lists:map(fun({Id, {Props}}) -> update_alternative(PollId, Id, Props) end, Changes).

create_poll(Title) ->
	Poll = #poll{id = kvs:next_id(poll, 1), title = filter:string(Title, 20, <<"poll">>)},
	kvs:put(Poll),
	Poll#poll.id.

api_event(create, Data, _) ->
	{Props} = jsone:decode(list_to_binary(Data)),
	Id = create_poll(proplists:get_value(<<"title">>, Props)),
	update_alternatives(Id, proplists:get_value(<<"changes">>, Props)),
	wf:redirect("/poll?id=" ++ wf:to_list(Id)).
	