-module(polls).
-compile(export_all).
-include_lib("records.hrl").

add_my(User, Poll) ->
	case kvs:index(my_poll, user_poll, {User, Poll}) of
		[] -> kvs:add(#my_poll{id=kvs:next_id(my_poll, 1), feed_id={my_polls, User}, user_poll={User, Poll}});
		M -> M
	end.

my(User) -> kvs:entries(kvs:get(feed, {my_polls, User}), my_poll, 10).

create(User) ->
	Id = vote_core:uuid(),
	kvs:put(#poll{id = Id, user=User, title = <<"poll">>}),
	add_my(User, Id),
	Id.

alts(Id) -> [A || A <- kvs:entries(kvs:get(feed, {alts, Id}), alt, undefined), A#alt.hidden == undefined].
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
		{U, _} = Vote#vote.user_poll,
		lists:foldl(fun (A, S) -> dict:append(A, {U, Vote#vote.name}, S) end, Sups, Ballot)
	end, dict:from_list([{A, []} || A <- alt_ids(Id)]), votes(Id)).

user_alts(Alts, Ballot, Seed) -> 
	B = maps:from_list(Ballot),
	A = lists:zip(vote_core:rand_seq(length(Alts), Seed), Alts),
	lists:reverse(lists:sort([{maps:get(Alt#alt.id, B, 0), Pos, Alt} || {Pos, Alt} <- A])).

first([], Default) -> Default;
first([First | _], _) -> First.

get_vote(User, Poll) ->	first(kvs:index(vote, user_poll, {User, Poll}), #vote{}).

put_vote(User, Poll, Name, Ballot) ->
	add_my(User, Poll),
	case get_vote(User, Poll) of
		#vote{id = []} -> 
			Id = kvs:next_id(vote, 1),
			kvs:add(#vote{id=Id, feed_id={votes, Poll}, user_poll={User, Poll}, name=Name, ballot=Ballot});
		Vote -> 
			kvs:put(Vote#vote{name=Name, ballot=Ballot})
	end.

get_alt(#poll{id = PollId}, Id) ->
	case kvs:get(alt, Id) of 
		{ok, Alt} -> 
			case Alt of
			% not that clear, but we get the alt only from this poll
				#alt{feed_id={alts, PollId}} -> Alt;
				_ -> undefined
			end;
		_ -> undefined
	end.
