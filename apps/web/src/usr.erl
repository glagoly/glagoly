-module(usr).
% usr because user is taken by erlang
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
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

fb_login(Token) ->
	Url = wf:to_list([
		"https://graph.facebook.com/v2.11/me",
		"?access_token=", Token]),
	{ok, {{_, 200, _}, _, Body}} = httpc:request(Url),
	Props = jsone:decode(list_to_binary(Body), [{object_format, proplist}]),
	Id = proplists:get_value(<<"id">>, Props),
	wf:info(?MODULE,"Url: ~p~n",[Id]).
	