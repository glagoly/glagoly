-module(view).

-export([init/1, event/1, api_event/3, create_panel/0, insert_bottom/2, title_input/2]).

-include_lib("nitro/include/nitro.hrl").
-include_lib("web.hrl").
-include_lib("records.hrl").

init(fb) ->
    nitro:wire(#api{name = fb_login, delegate = view}),
    nitro:wire("fb_init();");
init(navbar) ->
    nitro:clear(nav_links),
    case usr:state() of
        guest ->
            no;
        _ ->
            nitro:insert_bottom(nav_links, #li{
                class = 'nav-item',
                body = #link{
                    class = 'nav-link', body = ?T("Log out"), postback = logout, delegate = view
                }
            })
    end.

insert_bottom(Id, create_panel) ->
    nitro:insert_bottom(Id, view:create_panel());
insert_bottom(Id, login_panel) ->
    case usr:state() of
        pers ->
            already;
        _ ->
            nitro:insert_bottom(Id, login_panel()),
            view:init(fb)
    end.

api_event(fb_login, Token, _) ->
    usr:fb_login(Token),
    nitro:redirect("feed.html").

event(logout) ->
    usr:logout(),
    nitro:redirect("./");
event(create_poll) ->
    Title = filter:string(nitro:q(title), ?TITLE_MAX_LENGTH, ?T(title_sample)),
    Id = polls:create(usr:ensure(), Title),
    nitro:redirect("poll.html?new=1&id=" ++ Id);
event(_) ->
    ok.

%%%=============================================================================
%%% HTML Components
%%%=============================================================================

title_input(Title, ShowSamples) ->
    Samples = [
        #link{class = dotted, onclick = 'update_title_input(this)', body = S}
     || S <- ?T(title_samples)
    ],
    #panel{
        id = title_panel,
        body = [
            #textarea{
                id = title,
                maxlength = ?TITLE_MAX_LENGTH,
                class = 'form-control form-control-lg mb-2 mt-3',
                placeholder = ?T(title_sample),
                body = nitro:hte(Title),
                rows = 2
            },
            #p{
                class = 'mb-3 link-dark',
                body = case ShowSamples of
                    true -> [?T("Try:"), " &laquo;", lists:join("&raquo;, &laquo;", Samples), "&raquo;"];
                    _ -> []
                end
            }
        ]
    }.

login_panel() ->
    #panel{
        id = login_panel,
        class = 'mb-2',
        body = [
            #h2{class = 'display-6', body = ?T("Remember me")},
            #p{body = ?T(remember_me_info)},
            #panel{
                class = fb_wrapper,
                body = #panel{
                    class = 'fb-login-button d-inline-block',
                    body = ?T("Login with facebook"),
                    data_fields = [
                        {"data-size", large},
                        {"data-button-type", login_with},
                        {"data-layout", default},
                        {"data-auto-logout-link", false},
                        {"data-use-continue-as", false},
                        {"data-width", "260px"},
                        {"data-onlogin", checkLoginState}
                    ]
                }
            }
        ]
    }.

create_panel() ->
    #panel{
        id = create_panel,
        class = 'mb-3',
        body = [
            #h2{class = 'display-6', body = ?T("Create your poll")},
            title_input([], true),
            #button{
                class = 'btn btn-lg btn-success w-100',
                body = ?T("Create poll"),
                postback = create_poll,
                delegate = view,
                source = [title]
            }
        ]
    }.
