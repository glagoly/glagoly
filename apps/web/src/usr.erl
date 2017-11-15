-module(usr).
% usr because user is taken by erlang
-compile(export_all).
-include_lib("n2o/include/wf.hrl").

id() -> wf:user().

ensure() ->
	case wf:user() of
		undefined -> wf:user(kvs:next_id(user, 1));
		U -> U
	end.

seed() -> 
	case wf:user() of 
		undefined -> erlang:binary_to_integer(wf:session_id(), 16);
		U -> U
	end.