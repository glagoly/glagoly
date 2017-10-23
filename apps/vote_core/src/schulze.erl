-module(schulze).
-compile(export_all).

%% A New Monotonic, Clone-Independent,
%% Reversal Symmetric, and Condorcet-Consistent
%% Single-Winner Election Method

%% path strong comprasion >_d by winning votes
gt({E,F}, {G,H}) when E > F, G =< H -> true;
gt({E,F}, {G,H}) when E >= F, G < H -> true;
gt({E,F}, {G,H}) when E > F, G > H, E > G -> true;
gt({E,F}, {G,H}) when E > F, G > H, E =:= G, F < H ->true;
gt(_,_) -> false.

min_d(A,B) -> case gt(A,B) of true -> B; _ -> A	end.
max_d(A,B) -> case gt(A,B) of true -> A; _ -> B	end.

%% P[i,j] = {N[i,j], N[j,i]}
init(N) -> maps:map(fun ({R, C}, V) -> {V, maps:get({C, R}, N)} end, N).

strongest_path(P, Alts) ->
	lists:foldl(fun (I, P2) ->
		maps:map(fun ({J, K}, Pjk) ->
			case (I =/= J) and (I =/= K) and (J =/= K) of
				true -> max_d(Pjk, min_d(maps:get({J, I}, P2), maps:get({I, K}, P2)));
				_ -> Pjk
			end
		end, P2)
	end, P, Alts).

order(P, Alts) ->
	O = sets:from_list([{J, I} || {{J, I}, Pji} <- maps:to_list(P), J =/= I, gt(Pji, maps:get({I, J}, P))]),
	order(O, [], Alts).

order(_, Result, []) -> Result;
order(O, Result, Rest) -> 
	{Winners, Rest2} = lists:partition(fun (W) -> is_winner(O, W, Rest) end, Rest),
	order(O, Result ++ [Winners], Rest2).

is_winner(O, W, Rest) -> 
	lists:all(fun (C) -> not sets:is_element({C, W}, O) end, Rest).