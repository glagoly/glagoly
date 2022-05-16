-module(view_index).
-export([event/1, api_event/3]).

-include_lib("n2o/include/n2o.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").
-include_lib("web.hrl").

alt([]) ->
    <<"no vote">>;
alt([{A, _} | _]) ->
    {ok, Alt} = kvs:get(alt, A),
    wf:html_encode(Alt#alt.text).

poll({User, Poll}) ->
    {ok, P} = kvs:get(poll, Poll),
    V = polls:get_vote(User, Poll),
    #li{
        body = [
            #span{class = alt, body = alt(V#vote.ballot)},
            " in ",
            #link{
                href = "/" ++ Poll,
                body = #span{
                    class = poll, body = wf:html_encode(P#poll.title)
                }
            }
        ]
    }.

my_body(User, Js_escape) ->
    #panel{
        id = body,
        body = [
            view_common:top_bar(),
            #dtl{
                file = "my",
                js_escape = Js_escape,
                bindings = [
                    {polls, #ol{
                        class = alts, body = [poll(P#my_poll.id) || P <- polls:my(User)]
                    }},
                    {is_temp, not usr:is_pers()}
                ]
            }
        ]
    }.

my(User) ->
    view_common:page([
        {title, "my polls"},
        {body, my_body(User, false)}
    ]).

about() ->
    view_common:page([
        {title, "schulze polls online"},
        {description,
            "the fastest way to make micro-desicions, easy meeting schedule, fun rated lists"},
        {body, #dtl{
            file = "index",
            app = sample,
            bindings = [
                {cta, [
                    #h2{body = ?T("the fastest way <br /> to make micro-desicions")},
                    view_common:poll_button()
                ]},
                {create_button2, view_common:poll_button()}
            ]
        }}
    ]).

main() ->
    case usr:id() of
        undefined -> about();
        User -> my(User)
    end.

api_event(fb_login, Token, State) ->
    U = usr:fb_login(Token),
    view_common:wf_update(body, my_body(U, true)).

event(init) ->
    nitro:wire(#api{name = fb_login}),
    nitro:update(
        cta_create,
        #button{
            id = cta_create,
            class = 'btn btn-lg btn-success w-100 mb-5',
            body = ?T("Create poll"),
            postback = create_poll,
            delegate = view
        }
    );
event(_) ->
    ok.
