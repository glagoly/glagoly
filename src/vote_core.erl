-module(vote_core).

-export([new/0, add_alt/2, add_ballot/2, result/1, rand_seq/2]).

-record(poll, {alts, prefs}).

new() -> #poll{alts = [sq], prefs = #{{sq, sq} => 0}}.

alts(Poll) -> Poll#poll.alts.

result(Poll) ->
    P = schulze:init(Poll#poll.prefs),
    S = schulze:strongest_path(P, alts(Poll)),
    number_result(schulze:order(S, alts(Poll))).

maps_copy(Source, Dest, Map) -> maps:put(Dest, maps:get(Source, Map, 0), Map).

add_alt(Alt, Poll) ->
    Alts = ordsets:add_element(Alt, Poll#poll.alts),
    #poll{
        alts = Alts,
        prefs = lists:foldl(
            fun(Alt2, Acc) ->
                Acc2 = maps_copy({sq, Alt2}, {Alt, Alt2}, Acc),
                maps_copy({Alt2, sq}, {Alt2, Alt}, Acc2)
            end,
            Poll#poll.prefs,
            Alts
        )
    }.

normalize_ballot(Ballot, Alts) ->
    B = maps:from_list(Ballot),
    [{Alt, maps:get(Alt, B, 0)} || Alt <- Alts].

add_vote({A, Va}, {B, Vb}, Prefs, Weight) when Va > Vb ->
    maps:put({A, B}, maps:get({A, B}, Prefs) + Weight, Prefs);
add_vote({_, V}, {_, V}, Prefs, _) ->
    Prefs;
add_vote(A, B, Prefs, Weight) ->
    add_vote(B, A, Prefs, Weight).

add_votes([], Prefs, _) -> Prefs;
add_votes([A | Rest], Prefs, Weight) ->
    Prefs2 = lists:foldl(fun(B, P) -> add_vote(A, B, P, Weight) end, Prefs, Rest),
    add_votes(Rest, Prefs2, Weight).

add_ballot(Ballot, Poll) -> add_ballot(Ballot, Poll, 1).
add_ballot(Ballot, Poll, Weight) ->
    B = normalize_ballot(Ballot, alts(Poll)),
    #poll{alts = Poll#poll.alts, prefs = add_votes(B, Poll#poll.prefs, Weight)}.

pop_sq(Order) ->
    lists:foldl(
        fun(L, {Pos, Cur, Order2}) ->
            case lists:member(sq, L) of
                true -> {Cur, Cur + 1, Order2 ++ [lists:delete(sq, L)]};
                _ -> {Pos, Cur + 1, Order2 ++ [L]}
            end
        end,
        {undefined, 0, []},
        Order
    ).

number_result(Order) ->
    {P, Length, Order2} = pop_sq(Order),
    lists:foldl(
        fun ({Alts, B}, L) -> L ++ lists:zip(Alts, lists:duplicate(length(Alts), B)) end,
        [],
        lists:zip(Order2, lists:seq(P, P - Length + 1, -1))).

rand_seq(Length, Seed) ->
    rand:seed(exsss, {Seed, Seed, Seed}),
    [rand:uniform() || _ <- lists:seq(1, Length)].
