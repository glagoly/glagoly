-module(result).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

name_list(L) ->
	I = wf:user(),
	wf:info(?MODULE,"Props: ~p~n",[I, L]),
	L2 = lists:map(fun
		({U, _}) when U == I -> "<i>I</i>"; 
		({_, N}) -> wf:to_list(N)
	end, L),
	wf:info(?MODULE,"Props: ~p~n",[L2]),
	string:join(L2, ", ").

alt(Ids, Pos, Supps) ->
	Alts = [kvs:get(alt, Id) || Id <- Ids],
	R =[#li{body=[
		#span{class=vote, body=wf:to_list(Pos)},
		#span{class=text, body=Alt#alt.text},
		#span{class=supps, body=name_list(dict:fetch(Alt#alt.id, Supps))}
	]} || {ok, Alt} <- Alts].

results() -> 
	Supps = polls:supporters(poll_id()),
	[alt(Ids, P, Supps) || {Ids, P} <- polls:result(poll_id())].

main() ->
 	case kvs:get(poll, poll_id()) of
 		{ok, Poll} -> #dtl{file="results", bindings=[
			{title, wf:html_encode(Poll#poll.title)},
			{results, results()}
		]};
 		_ -> wf:state(status,404), "Poll not found" end.
