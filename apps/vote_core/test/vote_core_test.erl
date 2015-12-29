-module(vote_core_test).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

strongest_path_test() -> 
	?assert(vote_core:strongest_path(test) =:= ok).