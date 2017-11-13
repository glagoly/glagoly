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
	#li{body = #link{href = Poll, body = [
		#span{class=alt, body=alt(V#vote.ballot)},
		<<" in ">>,
		#span{class=poll, body=P#poll.title}
	]}}.

my() -> U = wf:user(), [poll(P#my_poll.user_poll) || P <- polls:my(U)].
	
main() ->
	#dtl{file="my", bindings=[
		{polls, my()}
	]}.

event(_) -> ok.