-module(samples).
-compile(export_all).
-include_lib("records.hrl").
-include_lib("n2o/include/wf.hrl").

polls() -> [poll, schedule, list].

names() -> [alice, bob, carol, dave, erin, frank].

title(poll) -> "Fenster poll";
title(schedule) -> "Weekend schedule";
title(list) -> "Coctail list".

alts(_) -> [
	{a, "Paint fenster in red"},
	{a, "Paint fenster in blue"},
	{a, "Remove fenster and make bicyle parking"},
	{e, "Replace fenster with metall one"},
	{f, "Leave fenster as is"}].
% alts(schedule) -> [];
% alts(list) -> [].

ballots(_) -> [
	{a, "Alice", [3, 1, 0, 0, 1]}
].

populate_poll(Poll) ->
	Id = "sample-" ++ wf:to_list(Poll),
	kvs:put(#poll{id = Id, user = a, title = wf:to_list(title(Poll))}),
	Alts = lists:map(fun({U, T}) ->
		A = kvs:next_id(alt, 1),
		kvs:add(#alt{id=A, user=U, feed_id={alts, Id}, text=T}),
		A
	end, alts(Poll)),
	lists:map(fun({U, N, B}) ->
		V = kvs:next_id(vote, 1),
		B2 = lists:zip(Alts, B),
		kvs:add(#vote{id=V, feed_id={votes, Id}, user_poll={U, Id}, name=N, ballot=B2})
	end, ballots(Poll)).

populate() ->
	[populate_poll(P)|| P <- polls()].
