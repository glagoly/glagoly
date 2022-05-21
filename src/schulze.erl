-module(schulze).

-export([init/1, strongest_path/2, order/2]).

%% A New Monotonic, Clone-Independent,
%% Reversal Symmetric, and Condorcet-Consistent
%% Single-Winner Election Method

%% path strong comprasion >_d by winning votes
gt({E, F}, {G, H}) when E > F, G =< H -> true;
gt({E, F}, {G, H}) when E >= F, G < H -> true;
gt({E, F}, {G, H}) when E > F, G > H, E > G -> true;
gt({E, F}, {G, H}) when E > F, G > H, E =:= G, F < H -> true;
gt(_, _) -> false.

min_d(A, B) ->
    case gt(A, B) of
        true -> B;
        _ -> A
    end.
max_d(A, B) ->
    case gt(A, B) of
        true -> A;
        _ -> B
    end.

%% P[i,j] = {N[i,j], N[j,i]}
init(N) -> maps:map(fun({R, C}, V) -> {V, maps:get({C, R}, N)} end, N).

strongest_path(P, Alts) ->
    lists:foldl(
        fun(I, P2) ->
            maps:map(
                fun({J, K}, Pjk) ->
                    case (I =/= J) and (I =/= K) and (J =/= K) of
                        true -> max_d(Pjk, min_d(maps:get({J, I}, P2), maps:get({I, K}, P2)));
                        _ -> Pjk
                    end
                end,
                P2
            )
        end,
        P,
        Alts
    ).

order(P, Alts) -> order(P, Alts, []).

order(_, [], Result) ->
    Result;
order(P, Rest, Result) ->
    {W, R} = lists:partition(
        fun(W) ->
            lists:all(fun(O) -> not gt(maps:get({O, W}, P), maps:get({W, O}, P)) end, Rest)
        end,
        Rest
    ),
    order(P, R, Result ++ [W]).
