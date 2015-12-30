-module(vote_core).
-compile(export_all).

%% M[i,j] = M[j,i]
transpose([[]|_]) -> [];
transpose(M) ->
  [lists:map(fun hd/1, M) | transpose(lists:map(fun tl/1, M))].

%% P[i,j] = {N[i,j], N[j,i]}
init(N) -> 
	lists:zipwith(fun lists:zip/2, N, transpose(N)).

%% path strong comprasion >_d by winning votes
gt({E,F}, {G,H}) when E > F, G =< H -> true;
gt({E,F}, {G,H}) when E >= F, G < H -> true;
gt({E,F}, {G,H}) when E > F, G > H, E > G -> true;
gt({E,F}, {G,H}) when E > F, G > H, E =:= G, F < H ->true;
gt(_,_) -> false.

min_d(A,B) when gt(A,B)-> B;
min_d(A,_) -> A.

strongest_path(P) -> P.