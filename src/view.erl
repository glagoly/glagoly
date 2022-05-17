-module(view).

-export([event/1, create_panel/0, title_input/1]).

-include_lib("nitro/include/nitro.hrl").
-include_lib("web.hrl").
-include_lib("records.hrl").

event(logout) ->
    usr:logout(),
    wf:redirect("/");
event(create_poll) ->
    Title = filter:string(nitro:q(title), 128, ?T(title_sample)),
    Id = polls:create(usr:ensure(), Title),
    nitro:redirect("poll.html?id=" ++ Id);
event(_) ->
    ok.

%%%=============================================================================
%%% HTML Components
%%%=============================================================================

title_input(Title) ->
    Samples = [
        #link{class = dotted, onclick = 'update_title_input(this)', body = S}
     || S <- ?T(title_samples)
    ],
    #panel{
        id = title_panel,
        body = [
            #input{
                id = title,
                data_fields = [{maxlength, ?TITLE_MAX_LENGTH}],
                class = 'form-control form-control-lg mb-2',
                placeholder = nitro:hte(Title),
                value = nitro:hte(Title)
            },
            #p{
                class = 'lead mb-4',
                body = [?T("Try:"), " &laquo;", lists:join("&raquo;, &laquo;", Samples), "&raquo;"]
            }
        ]
    }.

create_panel() ->
    #panel{
        id = create_panel,
        body = [
            #h2{class = 'display-6 mb-3 mt-5', body = ?T("Create your poll")},
            title_input(?T(title_sample)),
            #button{
                class = 'btn btn-lg btn-success w-100',
                body = ?T("Create poll"),
                postback = create_poll,
                delegate = view,
                source = [title]
            }
        ]
    }.
