-module(view_poll).
-export([event/1, api_event/3]).

-include_lib("n2o/include/n2o.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").
-include_lib("web.hrl").

-define(ALT_ID(Alt, Sub), nitro:to_list([alt, polls:id(Alt), Sub])).

poll_id() -> nitro:to_list(nitro:qc(id)).

poll() ->
    {ok, Poll} = kvs:get(poll, poll_id()),
    Poll.

win_vote([{V, _} | _]) when V > 0 -> V;
win_vote(_) -> 1.

can(access, Poll) ->
    case polls:access(Poll) of
        verified -> (usr:state() == pers);
        _ -> true
    end.

event(init) ->
    case kvs:get(poll, poll_id()) of
        {ok, _} ->
            view:init(navbar),
            case polls:get_ballot(usr:id(), poll_id()) of
                B when map_size(B) == 0 -> event(view_vote);
                _ -> event(view_results)
            end;
        _ ->
            nitro:redirect("404.html")
    end;
event(view_vote) ->
    case can(access, poll()) of
        true -> view_vote();
        false -> view_wall()
    end;
event(view_results) ->
    Poll = poll(),
    {Result, VoteCount} = polls:result(poll_id()),
    nitro:update(top, results_title(Poll, VoteCount)),
    nitro:clear(alts),
    Win = win_vote(Result),
    Voters = polls:voters(poll_id()),
    [
        nitro:insert_bottom(
            alts, result(polls:get_alt(Poll, AltId), V, V == Win, maps:get(AltId, Voters, []))
        )
     || {V, AltId} <- Result
    ],
    nitro:clear(bottom),
    nitro:insert_bottom(bottom, change_button()),
    view:insert_bottom(bottom, login_panel),
    case polls:can_edit(usr:id(), Poll) of
        true -> nitro:insert_bottom(bottom, share_panel(Poll));
        _ -> view:insert_bottom(bottom, create_panel)
    end;
event(add_alt) ->
    true = can(access, poll()),
    case filter:string(nitro:q(alt_text), ?ALT_MAX_LENGTH, []) of
        [] ->
            no;
        Text ->
            Alt = polls:append_alt(poll_id(), Text, usr:ensure()),
            nitro:insert_bottom(alts, alt(Alt, 0, true)),
            nitro:wire(#jq{target = alt_text, property = value, right = ""})
    end;
event({alt, Op, Id}) ->
    Poll = poll(),
    Alt = polls:get_alt(Poll, Id),
    true = polls:can_edit(usr:id(), Poll, Alt),
    true = can(access, Poll),
    nitro:update(?ALT_ID(Alt, panel), alt_event(Op, Alt));
event(_) ->
    ok.

view_vote() ->
    Poll = poll(),
    User = usr:id(),
    case polls:can_edit(usr:id(), Poll) of
        true -> nitro:update(top, title_input(Poll));
        _ -> nitro:update(top, title(Poll))
    end,
    nitro:clear(alts),
    Alts = polls:user_alts(User, poll_id(), usr:seed()),
    [nitro:insert_bottom(alts, alt(Alt, V, polls:can_edit(User, Poll, Alt))) || {V, Alt} <- Alts],
    nitro:clear(bottom),
    nitro:insert_bottom(bottom, add_alt_form()),
    case polls:can_edit(usr:id(), Poll) of
        true -> nitro:insert_bottom(bottom, access_panel(polls:access(Poll)));
        _ -> none
    end,
    nitro:insert_bottom(bottom, vote_form(polls:name(User, poll_id()), nitro:qc(new) /= undefined)).

view_wall() ->
    Poll = poll(),
    nitro:update(top, title(Poll)),
    nitro:clear(alts),
    nitro:insert_bottom(alts, wall_panel(polls:name(Poll))),
    nitro:clear(bottom),
    nitro:insert_bottom(bottom, results_button()),
    view:init_fb(view_poll).

alt_event(edit, Alt) ->
    edit_alt_form(Alt);
alt_event(cancel_edit, Alt) ->
    alt(Alt, polls:vote(usr:id(), Alt), true);
alt_event(save, Alt) ->
    New =
        case filter:string(nitro:q(?ALT_ID(Alt, new)), ?ALT_MAX_LENGTH, []) of
            [] -> Alt;
            T -> polls:update(Alt, usr:id(), T)
        end,
    alt(New, polls:vote(usr:id(), New), true);
alt_event(delete, Alt) ->
    polls:delete(Alt),
    restore_alt(Alt);
alt_event(restore, Alt) ->
    polls:restore(Alt),
    alt(Alt, polls:vote(usr:id(), Alt), true).

filter_votes(Votes) ->
    % to pairs {list(), int()}
    P1 = [{nitro:to_list(A), filter:in_range(binary_to_integer(V), -3, 7)} || [A, V] <- Votes],
    lists:filter(fun({_, V}) -> (V /= 0) end, P1).

api_event(fb_login, Token, _) ->
    usr:fb_login(Token),
    event(init);
api_event(vote, Data, _) ->
    Props = jsone:decode(list_to_binary(Data)),
    User = usr:ensure(),
    Poll = poll(),
    true = can(access, Poll),
    case polls:can_edit(User, Poll) of
        true ->
            Title = filter:string(
                maps:get(<<"title">>, Props), ?TITLE_MAX_LENGTH, polls:title(Poll)
            ),
            Access =
                case maps:get(<<"access">>, Props) of
                    <<"verified">> -> verified;
                    _ -> public
                end,
            polls:update(Poll, Title, Access);
        false ->
            ok
    end,

    Name = filter:string(maps:get(<<"name">>, Props), ?NAME_MAX_LENGTH, <<"anon">>),
    Votes = filter_votes(maps:get(<<"votes">>, Props)),
    polls:put_vote(User, poll_id(), Name, Votes),

    event(view_results).

%%%=============================================================================
%%% HTML Components
%%%=============================================================================

title_input(Poll) ->
    #panel{id = top, class = 'mb-4', body = view:title_input(polls:title(Poll), false)}.

title(Poll) ->
    #panel{
        id = top,
        body = [
            #h1{class = 'display-5 mt-3', body = nitro:hte(polls:title(Poll))},
            #p{class = 'lead text-muted mb-3', body = nitro:hte(polls:name(Poll))}
        ]
    }.

results_title(Poll, VoteCount) ->
    #panel{
        id = top,
        body = [
            #h1{class = 'display-5 mt-3', body = nitro:hte(polls:title(Poll))},
            #p{
                class = 'lead text-muted mb-3',
                body = [
                    nitro:hte(polls:name(Poll)), <<", ">>, nitro:to_list(VoteCount), <<"&check;">>
                ]
            }
        ]
    }.

badge_class(I) ->
    if
        I > 0 -> 'bg-success';
        I < 0 -> 'bg-danger';
        I == 0 -> ''
    end.

if_true(true, Value) -> Value;
if_true(_, _) -> [].

vote_buttons(Vote, Alt) ->
    Options = [
        {-3, 'btn-outline-danger'},
        {-1, 'btn-outline-danger'},
        {1, 'btn-outline-success ms-2'},
        {3, 'btn-outline-success'},
        {5, 'btn-outline-success'},
        {7, 'btn-outline-success'}
    ],
    Options2 = [{V, [C, if_true(Vote == V, ' active')]} || {V, C} <- Options],
    #panel{
        class = vote_buttons,
        body = [
            [
                #button{
                    class = ['btn', Class],
                    onclick = "onVoteClick(this)",
                    data_fields = [{'data-value', Value}],
                    body = filter:pretty_int(Value)
                }
             || {Value, Class} <- Options2
            ],
            #input{
                type = hidden,
                autocomplete = off,
                value = Vote,
                data_fields = [{'data-alt-id', polls:id(Alt)}]
            }
        ]
    }.

voter({Name, Vote}) when Vote < 0 ->
    #span{class = 'text-muted', body = [nitro:hte(Name), " ", filter:pretty_int(Vote)]};
voter({Name, Vote}) ->
    #span{body = [nitro:hte(Name), " ", filter:pretty_int(Vote)]}.

result(Alt, Vote, IsWinner, Voters) ->
    #panel{
        id = ?ALT_ID(Alt, panel),
        class =
            case IsWinner of
                true -> 'card mb-3 bg-light';
                _ -> 'card mb-3'
            end,
        body = [
            #panel{class = 'card-body', body = alt_p(Alt)},
            #panel{
                class = 'card-footer',
                body = #panel{
                    class = 'row align-items-center',
                    body = [
                        #panel{
                            class = 'col-2',
                            body = #h4{
                                class = 'text-center mb-0',
                                body = #span{
                                    id = ?ALT_ID(Alt, badge),
                                    body = filter:pretty_int(Vote),
                                    class = ['badge', 'bg-secondary', badge_class(Vote)]
                                }
                            }
                        },
                        #panel{
                            class = 'col-10 small',
                            body = lists:join(", ", [voter(V) || V <- Voters])
                        }
                    ]
                }
            }
        ]
    }.

alt_p(Alt) ->
    #p{
        class = 'card-text',
        body = [
            #span{class = 'small text-muted', body = nitro:hte(polls:name(Alt))},
            #br{},
            nitro:hte(polls:text(Alt))
        ]
    }.

alt(Alt, Vote, CanEdit) ->
    #panel{
        id = ?ALT_ID(Alt, panel),
        class = 'card mb-3',
        body = [
            #panel{
                class = 'card-body',
                body = [
                    #button{
                        show_if = CanEdit,
                        class = 'btn btn-sm btn-secondary float-end',
                        body = ?T("edit"),
                        postback = {alt, edit, polls:id(Alt)}
                    },
                    alt_p(Alt),
                    vote_buttons(Vote, Alt)
                ]
            }
        ]
    }.

restore_alt(Alt) ->
    #p{
        id = ?ALT_ID(Alt, panel),
        class = 'text-muted',
        body = [
            #link{
                class = 'link-secondary dotted',
                postback = {alt, restore, polls:id(Alt)},
                body = ?T("Restore")
            },
            " ",
            ?T("deleted alterntive.")
        ]
    }.

edit_alt_form(Alt) ->
    #panel{
        id = ?ALT_ID(Alt, panel),
        class = 'card mb-3',
        body = [
            #panel{
                class = 'card-body',
                body = #textarea{
                    id = ?ALT_ID(Alt, new),
                    body = nitro:hte(polls:text(Alt)),
                    maxlength = ?ALT_MAX_LENGTH,
                    class = 'form-control',
                    rows = 3
                }
            },
            #panel{
                class = 'card-footer text-end',
                body = [
                    #button{
                        class = 'btn btn-danger btn-sm float-start',
                        body = ?T("Remove"),
                        postback = {alt, delete, polls:id(Alt)}
                    },
                    #button{
                        class = 'btn btn-secondary btn-sm',
                        body = ?T("Cancel"),
                        postback = {alt, cancel_edit, polls:id(Alt)}
                    },
                    #button{
                        class = 'btn btn_brand btn-sm ms-3',
                        body = ?T("Save"),
                        postback = {alt, save, polls:id(Alt)},
                        source = [?ALT_ID(Alt, new)]
                    }
                ]
            }
        ]
    }.

add_alt_form() ->
    #panel{
        class = 'card mb-3',
        body = [
            #panel{class = 'card-header', body = ?T("Add my alternative")},
            #panel{
                class = 'card-body',
                body = #textarea{
                    id = alt_text, maxlength = ?ALT_MAX_LENGTH, class = 'form-control', rows = 3
                }
            },
            #panel{
                class = 'card-footer text-end',
                body = #button{
                    id = send,
                    class = 'btn btn_brand btn-sm',
                    body = ?T("Add"),
                    postback = add_alt,
                    source = [alt_text]
                }
            }
        ]
    }.

radio_button(Value, Checked, Text1, Text2) ->
    Id = nitro:to_list([access, Value]),
    #panel{
        class = 'form-check',
        body = [
            #label{
                class = 'form-check-label',
                for = Id,
                body = [
                    ?T(Text1), <<"<br><small class=\"text-muted\">">>, ?T(Text2), <<"</small>">>
                ]
            },
            #radio{
                id = Id, class = 'form-check-input', name = access, value = Value, checked = Checked
            }
        ]
    }.

access_panel(Access) ->
    #panel{
        class = 'mt-4',
        body = [
            radio_button(public, (Access == public), "Public poll", public_access_info),
            radio_button(verified, (Access == verified), "Verified poll", verified_access_info)
        ]
    }.

vote_form(Name, IsNew) ->
    nitro:wire(#api{name = vote}),
    [
        % Not Great, Not Terrible
        <<"<form class='mt-4' novalidate onsubmit='voteSubmit(event); return false;'>">>,
        #label{class = 'form-label', body = ?T("Your name")},
        #textbox{
            id = name,
            disabled = [],
            class = 'form-control',
            maxlength = ?NAME_MAX_LENGTH,
            value = nitro:hte(Name),
            required = true
        },
        #panel{class = 'invalid-feedback', body = ?T("Please enter your name")},
        #panel{
            body =
                case IsNew of
                    true ->
                        #submit{
                            class = 'btn btn-lg btn-success w-100 mt-4',
                            body = ?T("Create poll"),
                            click = []
                        };
                    _ ->
                        [
                            #submit{
                                class = 'btn btn-lg btn-success w-100 mt-4',
                                body = ?T("Vote"),
                                click = []
                            },
                            results_button()
                        ]
                end
        },
        <<"</form>">>
    ].

results_button() ->
    button("View results", ['w-100', 'btn-outline-secondary', 'mt-2'], view_results).
change_button() -> button("Change vote", [btn_brand, 'w-100', 'mb-4'], view_vote).

button(Body, Class, Postback) ->
    #button{class = [btn] ++ Class, body = ?T(Body), postback = Postback}.

share_panel(Poll) ->
    #panel{
        id = share_panel,
        class = 'mb-3',
        body = [
            #h2{class = 'display-6', body = ?T("Invite others")},
            #p{
                body =
                    case polls:access(Poll) of
                        verified -> ?T(verified_access_info);
                        _ -> ?T(public_access_info)
                    end
            },
            #textbox{
                id = share_url,
                class = 'form-control form-control-lg mb-3 text-center',
                disabled = [],
                readonly = true,
                data_fields = [{'data-text', ?T("Copied...")}],
                value = nitro:to_list(["https://glagoly.com/", polls:id(Poll)])
            },
            #button{
                class = 'btn btn-success w-100', body = ?T("Copy"), onclick = 'copy_share();'
            }
        ]
    }.

fake_alt() ->
    #panel{
        class = 'card mb-3',
        body = [
            #panel{
                class = 'card-body',
                body = [
                    #p{
                        class = 'card-text',
                        body = [
                            "Lorem ipsum dolor sit amet",
                            #br{},
                            #span{class = 'small text-muted', body = "Name"}
                        ]
                    },
                    vote_buttons(0, #alt{id = 0})
                ]
            }
        ]
    }.

wall_panel(Name) ->
    #panel{
        class = 'position-relative mb-4',
        body = [
            #panel{
                class = 'topper position-absolute',
                body = #panel{
                    class = 'card m-3 mt-5',
                    body = #panel{
                        class = 'card-body',
                        body = [
                            #h3{body = ?T("Please log in")},
                            #p{body = ?T(verified_access_wall)},
                            #p{class = 'text-muted', body = nitro:hte(Name)},
                            view:fb_login_button()
                        ]
                    }
                }
            },
            #panel{
                class = blur,
                body = [fake_alt() || _ <- lists:seq(1, 3)]
            }
        ]
    }.
