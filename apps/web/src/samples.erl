-module(samples).
-compile(export_all).
-include_lib("records.hrl").
-include_lib("n2o/include/wf.hrl").

polls() -> [poll, schedule, list].

title(poll) -> "Fenster poll";
title(schedule) -> "Weekend schedule";
title(list) -> "Coctail list".

populate() ->
	[kvs:put(#poll{
		id = "sample-" ++ wf:to_list(P),
		user=1,
		title = wf:to_list(title(P))}
		) || P <- polls()].
