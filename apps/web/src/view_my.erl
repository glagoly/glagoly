-module(view_my).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

alt([]) -> <<"No vote">>;
alt([{A, _} | _]) -> {ok, Alt} = kvs:get(alt, A), Alt#alt.text.

poll({User, Poll}) ->
	{ok, P} = kvs:get(poll, Poll),
	V = polls:get_vote(User, Poll),
	#li{body = [
		#span{class=alt, body=alt(V#vote.ballot)},
		<<" in ">>,
		#link{href = "p?ll=" ++ Poll, body = #span{class=poll, body=P#poll.title}}
	]}.

my() -> U = usr:id(), [poll(P#my_poll.user_poll) || P <- polls:my(U)].
	
main() ->
	#dtl{file="my", bindings=[
		{polls, my()}
	]}.

event(_) -> ok.