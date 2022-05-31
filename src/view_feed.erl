-module(view_feed).
-export([event/1]).

-include_lib("web.hrl").
-include_lib("nitro/include/nitro.hrl").

event(init) ->
    case usr:id() of
        guest ->
            nitro:redirect("./");
        User ->
            nitro:clear(top),
            case usr:state() of
                temp ->
                    nitro:insert_bottom(top, view:login_panel()),
                    view:init(fb);
                _ ->
                    already
            end,
            nitro:insert_bottom(top, view:create_panel()),
            view:init(navbar),
            case polls:my(User) of
                [] ->
                    empty;
                Polls ->
                    nitro:clear(polls),
                    nitro:insert_bottom(polls, header()),
                    [nitro:insert_bottom(polls, poll(polls:get(P))) || P <- Polls]
            end
    end;
event(_) ->
    ok.

%%%=============================================================================
%%% HTML Components
%%%=============================================================================

header() -> #h1{class = 'display-6 mb-3', body = ?T("My polls")}.

poll(Poll) ->
    #panel{
        class = 'card mb-3',
        body = [
            #panel{
                class = 'card-body',
                body = [
                    #p{
                        class = 'card-text lead',
                        body = [
                            nitro:hte(polls:title(Poll)),
                            #br{},
                            #link{
                                class = 'btn btn_brand btn-sm float-end',
                                body = ?T("Results"),
                                href = "poll.html?id=" ++ polls:id(Poll)
                            },
                            #span{class = 'small text-muted', body = nitro:hte(polls:name(Poll))}
                        ]
                    }
                ]
            }
        ]
    }.
