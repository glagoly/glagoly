-module(vote_core).
-compile(export_all).

%% M[i,j] = M[j,i]
transpose([[]|_]) -> [];
transpose(M) ->
  [lists:map(fun hd/1, M) | transpose(lists:map(fun tl/1, M))].

%% P[i,j] = {N[i,j], N[j,i]}
init(N) -> lists:zipwith(fun lists:zip/2, N, transpose(N)).

%% path strong comprasion >_d by winning votes
gt({E,F}, {G,H}) when E > F, G =< H -> true;
gt({E,F}, {G,H}) when E >= F, G < H -> true;
gt({E,F}, {G,H}) when E > F, G > H, E > G -> true;
gt({E,F}, {G,H}) when E > F, G > H, E =:= G, F < H ->true;
gt(_,_) -> false.

min_d(A,B) -> case gt(A,B) of true -> B; _ -> A	end.
max_d(A,B) -> case gt(A,B) of true -> A; _ -> B	end.

strongest_path(P) -> strongest_path(P, 1).

strongest_path(P, I) when I > length(P) -> P;
strongest_path(P, I) ->
	Pi = lists:nth(I, P),
	P_i = lists:map(fun(R) -> lists:nth(I, R) end, P),
	{P2, _} = lists:mapfoldl(
		fun({Pj, Pji}, J) -> {strongest_path_row(Pj, Pi, Pji, I, J), J + 1} end, 
		1, lists:zip(P, P_i)),
	strongest_path(P2, I + 1).

strongest_path_row(Pj, _, _, I, J) when I =:= J -> Pj;
strongest_path_row(Pj, Pi, Pji, I, J) ->
	{Pj2, _} = lists:mapfoldl(
		fun({Pjk, Pik}, K) -> {strongest_path_cell(Pjk, Pji, Pik, I, J, K), K + 1} end, 
		1, lists:zip(Pj, Pi)),
	Pj2.

strongest_path_cell(Pjk, _, _, I, J, K) when I =:= K; J =:= K -> Pjk;
strongest_path_cell(Pjk, Pji, Pik, _, _, _) -> max_d(Pjk, min_d(Pji, Pik)). 
