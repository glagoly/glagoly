-module(feed).
-compile(export_all).
-include_lib("records.hrl").

put_user_ballot(User, Poll, Ballot) ->
	kvs:put(#user_ballot{id = {User, Poll}, ballot=Ballot}).

create_poll(User) ->
	Id = vote_core:uuid(),
	kvs:put(#poll{id = Id, user=User, title = <<"poll">>}),
	Id.

get_ballot(User, Poll) ->
	Id = case kvs:get(user_ballot, {User, Poll}) of
		{ok, U} -> U#user_ballot.ballot;
		_ -> undefined
	end,
	case kvs:get(ballot, Id) of
		{ok, B} -> B;
		_ -> undefined
	end.

put_ballot(User, Poll, Name, Prefs) ->
	Id = case kvs:get(user_ballot, {User, Poll}) of
		{ok, U} -> U#user_ballot.ballot;
		_ -> kvs:next_id(ballot, 1)
	end,
	Ballot = #ballot{id=Id, feed_id={votes, Poll}, name=Name, prefs=Prefs},
	kvs:add(Ballot),
	put_user_ballot(User, Poll, Id).