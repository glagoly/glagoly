-module(view_feed).
-export([event/1]).

-include_lib("web.hrl").
-include_lib("nitro/include/nitro.hrl").

event(init) ->
    io:format("ID: ~p~n", [usr:id()]),
    case usr:id() of
        guest ->
            nitro:redirect("./");
        User ->
            view:init(navbar),
            case polls:my(User) of
                [] -> empty;
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

header() -> #h1{class = 'display-6 mb-3 mt-5', body = ?T("My polls")}.

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
                            #span{class = 'small text-muted', body = nitro:hte(polls:name(Poll))}
                        ]
                    }
                ]
            },
            #panel{
                class = 'card-footer text-end',
                body = #link{
                    class = 'btn btn-primary btn-sm',
                    body = ?T("Results"),
                    href = "poll.html?id=" ++ polls:id(Poll)
                }
            }
        ]
    }.
