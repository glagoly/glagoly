-module(create).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").

main() -> 
 	wf:wire(#api{name=create}),
	#dtl{file="create"}.

event(_) -> ok.

create_poll(Title) ->
	Id = kvs:next_id(poll, 1),
	Poll = #poll{id = Id, title = Title},
	kvs:put(Poll),
	Id.

api_event(create, Title, _) ->
	Id = create_poll(Title),
	wf:info(?MODULE,"Unknown Event: ~p~n",[Id]),
	wf:redirect("/poll?id=" ++ wf:to_list(Id)).
	