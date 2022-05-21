-module(view_index).
-export([event/1]).

-include_lib("nitro/include/nitro.hrl").
-include_lib("web.hrl").

event(init) ->
    case usr:state() of
        pers ->
            nitro:redirect("feed.html");
        _ ->
            nitro:wire(#api{name = fb_login, delegate = view}),
            nitro:update(
                cta_create,
                #button{
                    id = cta_create,
                    class = 'btn btn-lg btn-success w-100 mb-5',
                    body = ?T("Create poll"),
                    postback = create_poll,
                    delegate = view,
                    source = [title]
                }
            ),
            nitro:update(create_panel, view:create_panel())
    end;
event(_) ->
    ok.
