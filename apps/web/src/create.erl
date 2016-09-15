	-module(create).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

main() -> 
 	wf:wire(#api{name=create}),
	#dtl{file="create"}.

event(_) -> ok.

update_alternative(PollId, _, Text, true, _) ->
	Id = kvs:next_id(alternative, 1),
	kvs:add(#alternative{
		id=Id,
		feed_id={poll, PollId}, 
		text=Text}),
	Id.

update_alternatives(PollId, {Changes}) ->
	dict:from_list(lists:map(fun({Id, {Props}}) -> 
		{Id, update_alternative(
			PollId,
			Id,
			filter:string(proplists:get_value(<<"text">>, Props), 128, undefined),
			proplists:get_value(<<"new">>, Props),
			proplists:get_value(<<"deleted">>, Props))}
	end, Changes)).

create_poll(Title) ->
	Poll = #poll{id = kvs:next_id(poll, 1), title = filter:string(Title, 20, <<"poll">>)},
	kvs:put(Poll),
	Poll#poll.id.

vote(PollId, {Props}, Map) ->
	wf:info(?MODULE,"Props: ~p~n",[Props]),
	Votes = vote_core:key_group(lists:foldl(fun ({Id, Vote}, Votes) ->
		[{binary_to_integer(Vote), case dict:find(Id, Map) of
			{ok, Value} -> Value;
			_ -> binary_to_integer(Id)
		end} | Votes]
	end, [], Props)),
	kvs:add(#vote{
		id=kvs:next_id(vote, 1),
		feed_id={{poll, votes}, PollId}, 
		votes=Votes}),
	wf:info(?MODULE,"Votes: ~p~n",[Votes]),
	ok.

api_event(create, Data, _) ->
	{Props} = jsone:decode(list_to_binary(Data)),
	wf:info(?MODULE,"Props: ~p~n",[Props]),
	Id = create_poll(proplists:get_value(<<"title">>, Props)),
	Map = update_alternatives(Id, proplists:get_value(<<"changes">>, Props)),
	vote(Id, proplists:get_value(<<"votes">>, Props), Map),
	ok. %wf:redirect("/poll?id=" ++ wf:to_list(Id)).
	