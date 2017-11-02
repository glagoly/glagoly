-module(feed).
-compile(export_all).
-include_lib("records.hrl").

put_user_vote(User, Poll, Id) ->
	kvs:put(#user_poll{id = {User, Poll}, vote=Id}).

create_poll(User) ->
	Id = vote_core:uuid(),
	kvs:put(#poll{id = Id, user=User, title = <<"poll">>}),
	Id.

get_vote(User, Poll) ->
	Vote = case kvs:get(user_poll, {User, Poll}) of
		{ok, Id} -> case kvs:get(vote, Id) of {ok, V} -> V;	_ -> undefined end;
		_ -> undefined
	end.
	

put_ballot(User, Poll, Name, Prefs) -> ok.
	% Id = case kvs:get(user_poll, {User, Poll}) of
	% 	{ok, U} -> U#user_ballot.ballot;
	% 	_ -> kvs:next_id(ballot, 1)
	% end,
	% Ballot = #ballot{id=Id, feed_id={votes, Poll}, name=Name, prefs=Prefs},
	% kvs:add(Ballot),
	%put_user_ballot(User, Poll, Id).