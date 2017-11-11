-module(polls).
-compile(export_all).
-include_lib("records.hrl").
	
create(User) ->
	Id = vote_core:uuid(),
	kvs:put(#poll{id = Id, user=User, title = <<"poll">>}),
	Id.

alts(Id) -> kvs:entries(kvs:get(feed, {alts, Id}), alt, undefined).
alt_ids(Id) -> [Alt#alt.id || Alt <- alts(Id)].

votes(Id) -> kvs:entries(kvs:get(feed, {votes, Id}), vote, undefined).

result(Id) -> 
	V = lists:foldl(fun vote_core:add_alt/2, vote_core:new(), alt_ids(Id)),
	Ballots = [V#vote.ballot || V <- votes(Id)],
	P = lists:foldl(fun vote_core:add_ballot/2, V, Ballots),
	vote_core:result(P).

supporters(Id) ->
	lists:foldl(fun (Vote, Sups) ->
		Ballot = [A || {A, B} <- Vote#vote.ballot, B > 0, dict:is_key(A, Sups)],
		U = {Vote#vote.user, Vote#vote.name},
		lists:foldl(fun (A, S) -> dict:append(A, U, S) end, Sups, Ballot)
	end, dict:from_list([{A, []} || A <- alt_ids(Id)]), votes(Id)).

user_name(I, _, I) -> i;
user_name(User, Poll, I) ->
	case get_vote(User, Poll) of undefined -> []; V -> V#vote.name end.

get_vote(User, Poll) ->
	Vote = case kvs:get(user_poll, {User, Poll}) of
		{ok, U} -> 
			case kvs:get(vote, U#user_poll.vote) of 
				{ok, V} -> V;	
				_ -> undefined 
			end;
		_ -> undefined
	end.

user_alts(Alts, Ballot, Seed) -> 
	B = maps:from_list(Ballot),
	A = lists:zip(vote_core:rand_seq(length(Alts), Seed), Alts),
	lists:reverse(lists:sort([ {maps:get(Alt#alt.id, B, 0), Pos, Alt} || {Pos, Alt} <- A])).

put_vote(User, Poll, Name, Ballot) ->
	case get_vote(User, Poll) of
		undefined -> 
			Id = kvs:next_id(vote, 1),
			kvs:add(#vote{id=Id, feed_id={votes, Poll}, name=Name, ballot=Ballot}),
			kvs:put(#user_poll{id = {User, Poll}, vote=Id});
		Vote -> 
			kvs:put(Vote#vote{name=Name, ballot=Ballot})
	end.
