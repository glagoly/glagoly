-module(samples).
-compile(export_all).
-include_lib("records.hrl").
-include_lib("n2o/include/wf.hrl").

title(poll) -> "fence poll";
title(schedule) -> "weekend schedule";
title(list) -> "cocktail list".

alts(poll) -> [
		{a, "paint fence in red"},
		{a, "remove fence and make bicycle parking"},
		{a, "paint fence in blue"},
		{e, "replace fence with metal one"},
		{f, "leave fence as is"}
	];

alts(schedule) -> [
		{a, "play football on saturday morning"},
		{a, "make a barbecue on saturday morning"},
		{a, "drink beer at bar on friday evening"},
		{e, "make a skype conference on sunday morning"},
		{f, "just stay at home"}
	];

alts(list) -> [
		{a, "cosmopolitan"},
		{a, "sex on the beach"},
		{a, "long island iced tea"},
		{e, "blue hawaiian"},
		{f, "nonalcoholic mojito"}
	].

ballots(_) -> [
	{a, "Alice", [3, 1, 0, 0, -1]},
	{b, "Bob",   [1, 1, 0, 0, -1]},
	{c, "Carol", [1, 0, 1, 0, -1]},
	{d, "Dave",  [0, 0, 1, 0, -1]},
	{e, "Erin",  [0, 1, 0, 1, -1]},
	{f, "Frank", [0, 0, 0, -1, 1]}
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

