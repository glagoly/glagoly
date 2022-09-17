-module(filter).

-export([string/3, pretty_int/1, in_range/3]).

string(S, Length, Default) ->
    % 194 160 - non breakable space
    S1 = string:replace(S, <<194, 160>>, <<" ">>, all),
    case string:trim(S1) of
        [] -> Default;
        S2 -> string:slice(S2, 0, Length)
    end.

in_range(Int, Min, Max) ->
    if
        Int > Max -> Max;
        Int < Min -> Min;
        true -> Int
    end.

sign(I) ->
    if
        I > 0 -> 1;
        I < 0 -> -1;
        I == 0 -> 0
    end.

pretty_int(I) ->
    case sign(I) of
        0 -> "&empty;";
        1 -> ["+", nitro:to_list(I)];
        -1 -> ["&minus;", nitro:to_list(-I)]
    end.
