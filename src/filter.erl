-module(filter).

-export([string/3, int/4, pretty_int/1]).

string(Binary, Length, Default) ->
    S = string:strip(unicode:characters_to_list(Binary)),
    case lists:sublist(S, 1, Length) of
        [] -> Default;
        L -> unicode:characters_to_binary(L)
    end.

int(Binary, Min, Max, Default) when is_binary(Binary) ->
    int(wf:to_integer(Binary), Min, Max, Default);
int(Int, _, _, Default) when is_integer(Int) =/= true -> Default;
int(Int, Min, _, _) when Int < Min -> Min;
int(Int, _, Max, _) when Int > Max -> Max;
int(Int, _, _, _) ->
    Int.

pretty_int(Int) ->
    nitro:to_list(
        if
            Int == 0 -> "&empty;";
            Int > 0 -> ["+", Int];
            Int < 0 -> ["&minus;", -Int]
        end
    ).
