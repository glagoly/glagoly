-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

ensure_user() ->
	case wf:user() of
		undefined -> wf:user(kvs:next_id(user, 1));
		U -> U
	end.

main() -> 
	wf:info(?MODULE,"main loaded",[""]),
	#dtl{file="index", app=sample, bindings=[{create_button, #button{body="create poll",postback=create} }]}.

event(create) -> 
	Id = vote_core:uuid(),
	kvs:put(#poll{id = Id, user=ensure_user(), title = <<"poll">>}),
	wf:redirect("/edit?id=" ++ wf:to_list(Id));

event(_) -> ok.
