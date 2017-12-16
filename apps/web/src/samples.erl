-module(samples).
-compile(export_all).
-include_lib("records.hrl").
-include_lib("n2o/include/wf.hrl").

polls() -> [poll, schedule, list].

title(poll) -> "fence poll";
title(schedule) -> "Weekend schedule";
title(list) -> "Coctail list".

alts(_) -> [
		{a, "paint fence in red"},
		{a, "paint fence in blue"},
		{a, "remove fence and make bicycle parking"},
		{e, "replace fence with metal one"},
		{f, "leave fence as is"}
	].
% alts(schedule) -> [];
% alts(list) -> [].

ballots(_) -> [
	{a, "Alice", [3, 1, 0, 0, -1]},
	{b, "Bob",   [1, 1, 0, 0, -1]},
	{c, "Carol", [1, 0, 1, 0, -1]},
	{d, "Dave",  [0, 0, 1, 0, -1]},
	{e, "Erin",  [0, 1, 0, -1, -1]},
	{f, "Frank", [0, 0, 0, 1, 1]}
].

create(Type) ->
	Id = Id = vote_core:uuid(),
	kvs:put(#poll{id = Id, user = a, title = wf:to_list(title(Type))}),
	Alts = lists:map(fun({U, T}) ->
		A = kvs:next_id(alt, 1),
		kvs:add(#alt{id=A, user=U, feed_id={alts, Id}, text=T}),
		A
	end, alts(Type)),
	lists:map(fun({U, N, B}) ->
		V = kvs:next_id(vote, 1),
		B2 = lists:zip(Alts, B),
		kvs:add(#vote{id=V, feed_id={votes, Id}, user_poll={U, Id}, name=N, ballot=B2})
	end, ballots(Type)),
	Id.

