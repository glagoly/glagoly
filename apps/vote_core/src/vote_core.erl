-module(vote_core).
-compile(export_all).

init([ [ H | T ] | R]) -> 
	T2 = lists:zip(T, lists:map(fun hd/1, R)),
	R2 = init(lists:map(fun tl/1, R)),
	[ [{H, H} | T2 ] | lists:zipwith(fun({A, B}, T) -> [ {B, A} | T] end, T2, R2)];
init(_) -> [].

strongest_path(D) -> D.