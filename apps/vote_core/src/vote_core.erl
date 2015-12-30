-module(vote_core).
-compile(export_all).

%%
%% foreach i in len(a):
%%    foreach j in len(a):
%%       b[i,j] = [a[i,j], a[j,i]]
%% 
%% TODO: Make it simplier
%%
init([ [ H | T ] | R]) -> 
	T2 = lists:zip(T, lists:map(fun hd/1, R)),
	R2 = init(lists:map(fun tl/1, R)),
	[ [{H, H} | T2 ] | lists:zipwith(fun({A, B}, C) -> [ {B, A} | C] end, T2, R2)];
init(_) -> [].

%% path strong comprasion >_d by winning votes
gt({E,F}, {G, H}) when E > F, G =< H -> true;
gt({E,F}, {G, H}) when E => F, G < H -> true;
gt({E,F}, {G, H}) when E > F, G > H, E > G -> true;
gt({E,F}, {G, H}) when E > F, G > H, E = G, F < H ->true;
gt({E,F}, {G, H}) when E < F, G < H, E > G -> true;
gt({E,F}, {G, H}) when E < F, G < H, E = G, F < H ->true;
gt(_, _) -> false.

strongest_path(D) -> D.