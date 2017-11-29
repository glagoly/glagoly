-module(samples).
-compile(export_all).
-include_lib("records.hrl").
-include_lib("n2o/include/wf.hrl").

polls() -> [poll, schedule, list].

names() -> [alice, bob, carol, dave, erin, frank].

title(poll) -> "Fenster poll";
title(schedule) -> "Weekend schedule";
title(list) -> "Coctail list".

alts(poll) -> [
	{a, "Paint fenster in red"},
	{a, "Paint fenster in blue"},
	{a, "Remove fenster and make bicyle parking"},
	{e, "Replace fenster with metall one"},
	{f, "Leave fenster as is"}];
alts(schedule) -> [];
alts(list) -> [].

populate_poll(Poll) ->
	Id = "sample-" ++ wf:to_list(Poll),
	kvs:put(#poll{id = Id, user = a, title = wf:to_list(title(Poll))}),
	[kvs:add(#alt{id=kvs:next_id(alt, 1), user=U, feed_id={alts, Id}, text=T})
		|| {U, T} <- alts(Poll)].

populate() ->
	[populate_poll(P)|| P <- polls()].
