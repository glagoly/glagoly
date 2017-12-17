-module(result).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

poll_id() -> wf:to_list(wf:q(<<"id">>)).

name_list(L) ->
	I = usr:id(),
	L2 = lists:map(fun
		({I, _}) -> "<i>I</i>"; 
		({_, N}) -> wf:hte(wf:to_list(N))
	end, L),
	string:join(L2, ", ").

pos_format(P) when P > 0 -> "+" ++ wf:to_list(P);
pos_format(P) when P == 0 -> "";
pos_format(P) -> wf:to_list(P).

li_class(Pos) when Pos < 1 -> looser;
li_class(_) -> upwoted.

sups([]) -> "";
sups(S) -> #span{class=supps, body=name_list(S)}.

result(Ids, Pos, Supps, Classes) ->
	Alts = [kvs:get(alt, Id) || Id <- Ids],
	R =[#li{class=Classes ++ [li_class(Pos)] ,body=[
		#span{class=vote, body=pos_format(Pos)},
		#span{class=text, body=wf:hte(Alt#alt.text)},
		sups(dict:fetch(Alt#alt.id, Supps))
	]} || {ok, Alt} <- Alts].

results([]) -> [];
results([{Winners, Pw} | Other]) ->
	Supps = polls:supporters(poll_id()),
	O = [result(Ids, P, Supps, []) || {Ids, P} <- Other],
	result(Winners, Pw, Supps, [winner]) ++ O.

results() -> results(polls:result(poll_id())).

main() ->
 	case kvs:get(poll, poll_id()) of
 		{ok, Poll} -> #dtl{file="results", bindings=[
			{title, wf:html_encode(Poll#poll.title)},
			{results, results()}
		]};
 		_ -> wf:state(status,404), "Poll not found" end.
