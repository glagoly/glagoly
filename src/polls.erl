-module(polls).
-compile(export_all).
-include_lib("records.hrl").
-include_lib("web.hrl").

-define(ID_LENGTH, 7).

id(#alt{id = Id}) -> Id.

text(#alt{text = Text}) -> Text.

name(#alt{user = UserId}) -> "anonymous".

vote(UserId, #alt{poll = PollId}) -> 1.

title(#poll{title = Title}) -> Title.

can_edit(User, #poll{user = Author}) -> Author == User.
can_edit(User, Poll, #alt{user = Author}) -> can_edit(User, Poll) or (Author == User).

user_feed(User) -> "/user/" ++ User ++ "/polls".

add_my(User, Poll) -> kvs:append(#my_poll{id = {User, Poll}}, user_feed(User)).

my(User, Count) -> kvs:feed(user_feed(User)).

new_id() ->
    Id = small_id(),
    case kvs:get(poll, Id) of
        % try again if poll id already exists
        {ok, _} -> new_id();
        _ -> Id
    end.

today() -> erlang:system_time(second).

create(User, Title) ->
    Id = new_id(),
    kvs:put(#poll{id = Id, user = User, title = Title, date = today()}),
    add_my(User, Id),
    Id.

get_alt(#poll{id = PollId}, Id) ->
    {ok, Alt} = kvs:get(alt, Id),
    PollId = Alt#alt.poll,
    Alt.

alts_feed(Poll) -> "/poll/" ++ Poll ++ "/alts".

alts(PollId) -> [A || A <- kvs:feed(alts_feed(PollId)), A#alt.status == ok].

alt_ids(Id) -> [Alt#alt.id || Alt <- alts(Id)].

append_alt(PollId, Text, User) ->
    Alt = #alt{id = kvs:seq(alt, 1), poll = PollId, user = User, text = Text},
    kvs:append(Alt, alts_feed(PollId)),
    Alt.

votes(Id) -> kvs:entries(kvs:get(feed, {votes, Id}), vote, undefined).

result(Id) ->
    V = lists:foldl(fun vote_core:add_alt/2, vote_core:new(), alt_ids(Id)),
    Ballots = [V#vote.ballot || V <- votes(Id)],
    case Ballots of
        [B] ->
            vote_core:single_result(V, B);
        _ ->
            P = lists:foldl(fun vote_core:add_ballot/2, V, Ballots),
            vote_core:result(P)
    end.

% rename it as it now shows not only supportes
supporters(Id) ->
    lists:foldl(
        fun(Vote, Sups) ->
            Ballot = [{A, B} || {A, B} <- Vote#vote.ballot, B /= 0, dict:is_key(A, Sups)],
            {U, _} = Vote#vote.id,
            lists:foldl(
                fun({A, B}, S) -> dict:append(A, {U, Vote#vote.name, B}, S) end, Sups, Ballot
            )
        end,
        dict:from_list([{A, []} || A <- alt_ids(Id)]),
        votes(Id)
    ).

user_alts(User, Poll, Seed) ->
    Alts = alts(Poll),
    Vote = get_vote(User, Poll),
    Ballot = maps:from_list(Vote#vote.ballot),
    List = lists:sort(lists:zip3(
        [maps:get(Alt#alt.id, Ballot, 0) || Alt <- Alts],
        vote_core:rand_seq(length(Alts), Seed),
        Alts)),
    lists:reverse([{Ballot, Alt} || {Ballot, _, Alt} <- List]).

get_vote(User, Poll) -> case kvs:get(vote, {User, Poll}) of {ok, Vote} -> Vote; _ -> #vote{} end.

put_vote(User, Poll, Name, Ballot) ->
    % add_my(User, Poll),
    kvs:put(#vote{id = {User, Poll}, name = Name, ballot = Ballot, date=today()}).
    % case get_vote(User, Poll) of
    %     #vote{id = []} ->
    %         Id = kvs:next_id(vote, 1),
            
    %     Vote ->
    %         kvs:put(Vote#vote{name = Name, ballot = Ballot})
    % end.

merge_user(_, undefined) ->
    no;
merge_user(Old, New) ->
    [kvs:put(P#poll{user = Old}) || P <- kvs:index(poll, user, New)],
    [kvs:put(A#alt{user = Old}) || A <- kvs:index(alt, user, New)],
    lists:map(
        fun(#my_poll{id = {_, P}}) ->
            V = get_vote(New, P),
            kvs:remove(vote, V#vote.id),
            put_vote(Old, P, V#vote.name, V#vote.ballot)
        end,
        my(New, undefined)
    ).

small_id() ->
    Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
    [lists:nth(rand:uniform(length(Chars)), Chars) || _ <- lists:seq(1, ?ID_LENGTH)].
