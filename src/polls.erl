-module(polls).
-compile(export_all).
-include_lib("records.hrl").
-include_lib("web.hrl").

-define(ID_LENGTH, 7).

id(#alt{id = Id}) -> Id.

text(#alt{text = Text}) -> Text.

name(#alt{user = UserId}) -> "anonymous".

can_edit(User, #poll{user = Author}) -> Author == User.
can_edit(User, Poll, #alt{user = Author}) -> can_edit(User, Poll) or (Author == User).

add_my(User, Poll) ->
    case kvs:index(my_poll, user_poll, {User, Poll}) of
        [E] ->
            {ok, E2} = kvs:unlink(E),
            kvs:link(E2);
        _ ->
            kvs:add(#my_poll{id = kvs:next_id(my_poll, 1), user_poll = {User, Poll}})
    end.

my(User) -> my(User, 10).
my(User, Count) -> kvs:entries(kvs:get(feed, {my_polls, User}), my_poll, Count).

create(User) ->
    Id = small_id(),
    case kvs:get(poll, Id) of
        % try again if poll id already exists
        {ok, _} ->
            create(User);
        _ ->
            kvs:put(#poll{id = Id, user = User, title = ?T("What are we doing?")}),
            %add_my(User, Id),
            Id
    end.

alts(Id) ->
    [A || A <- kvs:entries(kvs:get(feed, {alts, Id}), alt, undefined), A#alt.hidden /= true].
alt_ids(Id) -> [Alt#alt.id || Alt <- alts(Id)].

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
            {U, _} = Vote#vote.user_poll,
            lists:foldl(
                fun({A, B}, S) -> dict:append(A, {U, Vote#vote.name, B}, S) end, Sups, Ballot
            )
        end,
        dict:from_list([{A, []} || A <- alt_ids(Id)]),
        votes(Id)
    ).

user_alts(Alts, Ballot, Seed) ->
    B = maps:from_list(Ballot),
    A = lists:zip(vote_core:rand_seq(length(Alts), Seed), Alts),
    lists:reverse(lists:sort([{maps:get(Alt#alt.id, B, 0), Pos, Alt} || {Pos, Alt} <- A])).

first([], Default) -> Default;
first([First | _], _) -> First.

get_vote(User, Poll) -> first(kvs:index(vote, user_poll, {User, Poll}), #vote{}).

put_vote(User, Poll, Name, Ballot) ->
    add_my(User, Poll),
    case get_vote(User, Poll) of
        #vote{id = []} ->
            Id = kvs:next_id(vote, 1),
            kvs:add(#vote{id = Id, user_poll = {User, Poll}, name = Name, ballot = Ballot});
        Vote ->
            kvs:put(Vote#vote{name = Name, ballot = Ballot})
    end.

get_alt(#poll{id = PollId}, Id) ->
    case kvs:get(alt, Id) of
        {ok, Alt} ->
            case Alt of
                % not that clear, but we get the alt only from this poll
                %#alt{feed_id={alts, PollId}} -> Alt;
                Alt -> Alt;
                _ -> undefined
            end;
        _ ->
            undefined
    end.

merge_user(_, undefined) ->
    no;
merge_user(Old, New) ->
    [kvs:put(P#poll{user = Old}) || P <- kvs:index(poll, user, New)],
    [kvs:put(A#alt{user = Old}) || A <- kvs:index(alt, user, New)],
    lists:map(
        fun(#my_poll{id = Id, user_poll = {_, P}}) ->
            kvs:delete(my_poll, Id),
            V = get_vote(New, P),
            kvs:remove(vote, V#vote.id),
            put_vote(Old, P, V#vote.name, V#vote.ballot)
        end,
        my(New, undefined)
    ).

small_id() ->
    Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
    [lists:nth(rand:uniform(length(Chars)), Chars) || _ <- lists:seq(1, ?ID_LENGTH)].
