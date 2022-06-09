-module(polls).

-include_lib("records.hrl").

-export([
    append_alt/3,
    can_edit/2, can_edit/3,
    create/2,
    delete/1,
    get/1,
    get_alt/2,
    get_ballot/2,
    id/1,
    merge_user/2,
    my/1,
    name/1, name/2,
    put_vote/4,
    result/1,
    restore/1,
    text/1,
    title/1,
    update/2,
    update/3,
    user_alts/3,
    vote/2,
    voters/1
]).

id(#alt{id = Id}) -> Id;
id(#poll{id = Id}) -> Id.

text(#alt{text = Text}) -> Text.

name(UserId, PollId) -> (get_vote(UserId, PollId))#vote.name.

name(#alt{poll = Id, user = UserId}) -> name(UserId, Id);
name(#poll{id = Id, user = UserId}) -> name(UserId, Id).

vote(UserId, #alt{id = Id, poll = PollId}) -> maps:get(Id, get_ballot(UserId, PollId), 0).

title(#poll{title = Title}) -> Title.

get(#my_poll{id = {_, PollId}}) ->
    {ok, Poll} = kvs:get(poll, PollId),
    Poll.

delete(Alt) when is_record(Alt, alt) -> kvs:put(Alt#alt{status = deleted}).
restore(Alt) when is_record(Alt, alt) -> kvs:put(Alt#alt{status = ok}).

update(Alt, User, Text) ->
    New = Alt#alt{user = User, text = Text},
    kvs:put(New),
    New.

can_edit(User, #poll{user = Author}) -> Author == User.
can_edit(User, Poll, #alt{user = Author}) -> can_edit(User, Poll) or (Author == User).

user_feed(User) -> "/user/" ++ User ++ "/polls".

add_my(User, Poll) -> kvs:append(#my_poll{id = {User, Poll}}, user_feed(User)).

my(User) -> kvs:feed(user_feed(User)).

new_id() ->
    Id = small_id(),
    % try again if poll id already exists
    case kvs:get(poll, Id) of
        {ok, _} -> new_id();
        _ -> Id
    end.

create(User, Title) ->
    Id = new_id(),
    kvs:put(#poll{id = Id, user = User, title = Title}),
    Id.

update(Poll, Title) when is_record(Poll, poll) -> kvs:put(Poll#poll{title = Title}).

get_alt(#poll{id = PollId}, Id) ->
    {ok, Alt} = kvs:get(alt, Id),
    PollId = Alt#alt.poll,
    Alt.

alts_feed(Poll) -> "/poll/" ++ Poll ++ "/alts".

alts(PollId) -> [A || A <- kvs:feed(alts_feed(PollId)), A#alt.status == ok].

append_alt(PollId, Text, User) ->
    Alt = #alt{id = kvs:seq(alt, 1), poll = PollId, user = User, text = Text},
    kvs:append(Alt, alts_feed(PollId)),
    Alt.

result(PollId) ->
    AltIds = [Alt#alt.id || Alt <- alts(PollId)],
    Ballots = [V#vote.ballot || V <- votes(PollId)],
    case Ballots of
        [Single] ->
            Ballot = maps:from_list(Single),
            Result = [{maps:get(AltId, Ballot, 0), AltId} || AltId <- AltIds],
            lists:reverse(lists:sort(Result));
        _ ->
            Core = lists:foldl(fun vote_core:add_alt/2, vote_core:new(), AltIds),
            Core2 = lists:foldl(fun vote_core:add_ballot/2, Core, Ballots),
            vote_core:result(Core2)
    end.

voters(Id) ->
    Votes = votes(Id),
    lists:foldl(
        fun(Vote, Voters) ->
            lists:foldl(
                fun({Alt, V}, Voters2) ->
                    maps:update_with(
                        Alt,
                        fun(V1) -> V1 ++ [{Vote#vote.name, V}] end,
                        [{Vote#vote.name, V}],
                        Voters2
                    )
                end,
                Voters,
                [{Alt, V} || {Alt, V} <- Vote#vote.ballot, V /= 0]
            )
        end,
        #{},
        Votes
    ).

user_alts(User, Poll, Seed) ->
    Alts = alts(Poll),
    Ballot = get_ballot(User, Poll),
    List = lists:sort(
        lists:zip3(
            [maps:get(Alt#alt.id, Ballot, 0) || Alt <- Alts],
            vote_core:rand_seq(length(Alts), Seed),
            Alts
        )
    ),
    lists:reverse([{B, Alt} || {B, _, Alt} <- List]).

votes_feed(PollId) -> "/poll/" ++ PollId ++ "/votes".

votes(PollId) -> [V || V <- kvs:feed(votes_feed(PollId)), V#vote.status == ok].

get_vote(User, Poll) ->
    case kvs:get(vote, {User, Poll}) of
        {ok, Vote} -> Vote;
        _ -> #vote{}
    end.

get_ballot(User, Poll) ->
    Vote = get_vote(User, Poll),
    maps:from_list(Vote#vote.ballot).

put_vote(User, PollId, Name, Ballot) ->
    case get_vote(User, PollId) of
        #vote{id = undefined} ->
            Vote = #vote{id = {User, PollId}, name = Name, ballot = Ballot},
            kvs:append(Vote, votes_feed(PollId)),
            add_my(User, PollId);
        Vote ->
            % restore vote (status = ok) in case it was removed
            kvs:put(Vote#vote{name = Name, ballot = Ballot, status = ok})
    end.

merge_user(Pers, Temp) ->
    [kvs:put(P#poll{user = Pers}) || P <- kvs:index(poll, user, Temp)],
    [kvs:put(A#alt{user = Pers}) || A <- kvs:index(alt, user, Temp)],
    lists:map(
        fun(#my_poll{id = {_, PollId}}) ->
            Vote = get_vote(Temp, PollId),
            kvs:put(Vote#vote{status = changed}),
            put_vote(Pers, PollId, Vote#vote.name, Vote#vote.ballot)
        end,
        my(Temp)
    ).

small_id() ->
    Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
    [lists:nth(rand:uniform(length(Chars)), Chars) || _ <- lists:seq(1, ?ID_LENGTH)].
