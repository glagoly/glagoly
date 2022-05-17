-module(view).

-export([event/1, create_panel/0, title_input/1]).

-include_lib("n2o/include/n2o.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("web.hrl").
-include_lib("records.hrl").

poll_button() -> poll_button([]).
poll_button(Class) ->
    #button{
        body = ?T("create poll"), class = Class, postback = create_poll, delegate = view_common
    }.

top_bar() ->
    #panel{
        class = 'navbar navbar-dark bg-primary',
        body = #panel{
            class = [container, main],
            body = [
                #link{
                    href = "/",
                    class = 'navbar-brand ms-2',
                    body = #image{
                        src = "/static/img/logo.svg",
                        height = 24,
                        width = 26,
                        class = "align-text-top ms-2"
                    }
                },
                #panel{
                    class = 'd-flex',
                    body = [
                        #button{
                            body = ?T("create"),
                            class = 'btn btn-success',
                            postback = create_poll,
                            delegate = view_common
                        },
                        case usr:is_pers() of
                            true ->
                                #button{
                                    body = ?T("logout"),
                                    class = 'btn btn-primary ms-2',
                                    delegate = view_common,
                                    postback = logout
                                };
                            _ ->
                                ""
                        end
                    ]
                }
            ]
        }
    }.

bindings() ->
    [
        {fb_app_id, wf:config(web, fb_app_id)},
        {ga_id, wf:config(web, ga_id)}
    ].

page(Bindings) ->
    wf:wire(#api{name = fb_login}),
    #dtl{file = "_page", bindings = bindings() ++ Bindings}.

event(logout) ->
    usr:logout(),
    wf:redirect("/");
% event(create_poll) ->
%     Id = polls:create(usr:ensure()),
%     wf:redirect("/" ++ wf:to_list(Id));
event(create_poll) ->
    Id = polls:create(usr:ensure(), ?T("Where and when do we meet?")),
    nitro:redirect("poll.html?id=" ++ Id);
event(_) ->
    ok.

%%%=============================================================================
%%% HTML Components
%%%=============================================================================

title_input(Title) ->
    #panel{
        id = top,
        body = [
            #label{class = <<"form-label mt-4">>, body = ?T("Poll title")},
            #input{
                id = title,
                data_fields = [{maxlength, ?TITLE_MAX_LENGTH}],
                class = <<"form-control form-control-lg mb-2">>,
                placeholder = Title,
                value = Title
            },
            #p{
                class = <<"lead mb-4">>,
                body = [
                    ?T("Try:"),
                    " &laquo;",
                    #link{
                        class = dotted,
                        onclick = 'update_title_input(this)',
                        body = ?T("Where and when do we meet?")
                    },
                    "&raquo;, &laquo;",
                    #link{
                        class = dotted,
                        onclick = 'update_title_input(this)',
                        body = ?T("What are we doing?")
                    },
                    "&raquo;, &laquo;",
                    #link{
                        class = dotted,
                        onclick = 'update_title_input(this)',
                        body = ?T("Where are we going?")
                    },
                    "&raquo;"
                ]
            }
        ]
    }.

create_panel() ->
    #panel{id=create_panel,body=[
            #h2{class='display-6 mb-3 mt-5', body=?T("Create your poll")},
            title_input("title"),
            #button{
                class = 'btn btn-lg btn-success w-100',
                body = ?T("Create poll"),
                postback = create_poll,
                delegate = view
            }
    ]}.