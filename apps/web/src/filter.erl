-module(filter).
-compile(export_all).

string(Binary, Length, Default) ->
	S = string:strip(unicode:characters_to_list(Binary)),
	case lists:sublist(S, 1, Length) of 
		[] -> Default;
  		L -> unicode:characters_to_binary(L)
  	end.