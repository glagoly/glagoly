-module(result).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

poll_alts() -> kvs:entries(kvs:get(feed, {alts, poll_id()}), alt, undefined).

poll_votes() -> kvs:entries(kvs:get(feed, {votes, poll_id()}), vote, undefined).

calc_result() ->
	Alts = [Alt#alt.id || Alt <- poll_alts()],
	V = lists:foldl(fun vote_core:add_alt/2, vote_core:new(), Alts),
	Ballots = [Alt#vote.prefs || Alt <- poll_votes()],
	P = lists:foldl(fun vote_core:add_ballot/2, V, Ballots),
	R = vote_core:result(P),
	wf:info(?MODULE, "prefs", R).

results() ->
	calc_result(),
	[].

main() ->
 	case kvs:get(poll, poll_id()) of
 		{ok, Poll} -> #dtl{file="results", bindings=[
			{title, wf:html_encode(Poll#poll.title)},
			{results, results()}
		]};
 		_ -> wf:state(status,404), "Poll not found" end.
