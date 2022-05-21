-module(view_feed).
-export([event/1]).

-include_lib("web.hrl").
-include_lib("records.hrl").
-include_lib("nitro/include/nitro.hrl").

event(init) ->
    case usr:id() of
        guest ->
            nitro:redirect("./");
        User ->
            view:init(navbar),
            Polls = polls:my(User),
            [nitro:insert_bottom(alts, poll(P#my_poll.id)) || P <- Polls]
    end;
event(_) ->
    ok.

%%%=============================================================================
%%% HTML Components
%%%=============================================================================

poll({_, PollId}) ->
    {ok, Poll} = kvs:get(poll, PollId),
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
