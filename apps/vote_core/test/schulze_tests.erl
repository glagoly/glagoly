-module(schulze_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

init_test() ->
	N = dict:from_list([
		{{a,a},1}, {{a,b},2},
		{{b,a},3}, {{b,b},4}]),
	P = dict:from_list([
		{{a,a},{1,1}}, {{a,b},{2,3}},
		{{b,a},{3,2}}, {{b,b},{4,4}}]),
	?assertEqual(P, schulze:init(N)).

min_d_test() ->
	?assertEqual({14,7}, schulze:min_d({14,7},{15,6})).	

max_d_test() ->
	?assertEqual({14,7}, schulze:max_d({14,7},{12,9})).	

%% Sample 1. Page 12
strongest_path_1_test() ->
	P = schulze:init(dict:from_list([
		{{a,a},nil}, {{a,b},8},   {{a,c},14},  {{a,d},10},
		{{b,a},13},  {{b,b},nil}, {{b,c},6},   {{b,d},2},
		{{c,a},7},   {{c,b},15},  {{c,c},nil}, {{c,d},12},
		{{d,a},11},  {{d,b},19},  {{d,c},9},   {{d,d},nil}])),
	P2 = lists:sort([
		{{a,a},{nil,nil}}, {{a,b},{14,7}},    {{a,c},{14,7}},    {{a,d},{12,9}},
		{{b,a},{13,8}},    {{b,b},{nil,nil}}, {{b,c},{13,8}},    {{b,d},{12,9}},
		{{c,a},{13,8}},    {{c,b},{15,6}},    {{c,c},{nil,nil}}, {{c,d},{12,9}},
		{{d,a},{13,8}},    {{d,b},{19,2}},    {{d,c},{13,8}},    {{d,d},{nil,nil}}]),
	Result = lists:sort(dict:to_list(schulze:strongest_path(P, sets:from_list([a,b,c,d])))),
	?assertEqual(P2, Result).

%% Sample 6. Page 26
strongest_path_6_test() ->
	P = schulze:init(dict:from_list([
		{{a,a},nil}, {{a,b},67},  {{a,c},28},  {{a,d},40},
		{{b,a},55},  {{b,b},nil}, {{b,c},79},  {{b,d},58},
		{{c,a},36},  {{c,b},59},  {{c,c},nil}, {{c,d},45},
		{{d,a},50},  {{d,b},72},  {{d,c},29},  {{d,d},nil}])),
	P2 = lists:sort([
		{{a,a},{nil,nil}}, {{a,b},{67,55}},    {{a,c},{67,55}},    {{a,d},{45,29}},
		{{b,a},{45,29}},   {{b,b},{nil,nil}},  {{b,c},{79,59}},    {{b,d},{45,29}},
		{{c,a},{45,29}},   {{c,b},{45,29}},    {{c,c},{nil,nil}},  {{c,d},{45,29}},
		{{d,a},{50,40}},   {{d,b},{72,58}},    {{d,c},{72,58}},    {{d,d},{nil,nil}}]),
	Result = lists:sort(dict:to_list(schulze:strongest_path(P, sets:from_list([a,b,c,d])))),
	?assertEqual(P2, Result).


%% Sample 6. Page 26
order_test() ->
	P = dict:from_list([
		{{a,a},{nil,nil}}, {{a,b},{67,55}},    {{a,c},{67,55}},    {{a,d},{45,29}},
		{{b,a},{45,29}},   {{b,b},{nil,nil}},  {{b,c},{79,59}},    {{b,d},{45,29}},
		{{c,a},{45,29}},   {{c,b},{45,29}},    {{c,c},{nil,nil}},  {{c,d},{45,29}},
		{{d,a},{50,40}},   {{d,b},{72,58}},    {{d,c},{72,58}},    {{d,d},{nil,nil}}]),
	?assertEqual([[d],[a],[b],[c]], schulze:order(P, [a, b, c, d])).

%% Sample 2. Page 16
order_tie_test() ->
	P = dict:from_list([
		{{a,a},{nil,nil}}, {{a,b},{5,4}},      {{a,c},{5,4}},      {{a,d},{5,4}},
		{{b,a},{5,4}},     {{b,b},{nil,nil}},  {{b,c},{7,2}},      {{b,d},{5,4}},
		{{c,a},{5,4}},     {{c,b},{5,4}},      {{c,c},{nil,nil}},  {{c,d},{5,4}},
		{{d,a},{6,3}},     {{d,b},{5,4}},      {{d,c},{5,4}},      {{d,d},{nil,nil}}]),
	?assertEqual([[b, d], [a, c]], schulze:order(P, [a, b, c, d])).