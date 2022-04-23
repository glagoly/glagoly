-module(view_poll).
-export([event/1, api_event/3]).

-include_lib("n2o/include/n2o.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").
-include_lib("web.hrl").

-define(TITLE_MAX_LENGTH, 64).
-define(ALT_MAX_LENGTH, 128).
-define(NAME_MAX_LENGTH, 32).

-define(ALT_ID(Alt, Sub), nitro:to_list([alt, polls:id(Alt), Sub])).

poll_id() -> nitro:to_list(nitro:qc(id)).

poll() ->
    io:format("ID: ~p~n", [poll_id()]),
    case kvs:get(poll, poll_id()) of
        {ok, Poll} -> Poll;
        _ -> undefined
    end.

author(I, _, I) ->
    <<"<i>I</i>">>;
author(User, Poll, _) ->
    case polls:get_vote(User, Poll) of
        #vote{name = []} -> <<"anonymous">>;
        #vote{name = Name} -> wf:html_encode(Name)
    end.

alt_link(Postback, Body, Alt) -> alt_link(Postback, Body, Alt, []).
alt_link(Postback, Body, Alt, Source) ->
    #link{
        id = wf:to_list([Postback, Alt#alt.id]),
        body = Body,
        class = Postback,
        postback = Postback,
        source = [{id, wf:to_list(["number(", Alt#alt.id, ")"])}] ++ Source
    }.

restore_alt(Alt) ->
    [
        #li{
            id = ?ALT_ID(Alt, ""),
            class = deleted,
            body = [
                alt_link(restore_alt, "Restore", Alt), " deleted alterntive"
            ]
        }
    ].

alt_text(Alt, Edit) ->
    [
        #panel{
            id = ?ALT_ID(Alt, text),
            body = [
                case Edit of
                    true ->
                        #span{
                            class = buttons,
                            body = [
                                alt_link(del_alt, "delete", Alt),
                                alt_link(edit_alt, "edit", Alt)
                            ]
                        };
                    _ ->
                        []
                end,
                #panel{
                    class = inner,
                    body = [
                        #span{body = []},
                        #span{class = author, body = author(Alt#alt.user, poll_id(), usr:id())}
                    ]
                }
            ]
        }
    ].

title(User, Poll) ->
    T = wf:html_encode(Poll#poll.title),
    case polls:can_edit(User, Poll) of
        true ->
            #textbox{
                id = title,
                maxlength = ?TITLE_MAX_LENGTH,
                class = 'title-input',
                placeholder = T,
                value = T
            };
        _ ->
            #h1{body = T, class = 'display-5 mb-3 mt-3'}
    end.

update_title(Poll, Title) ->
    User = usr:id(),
    case Poll#poll.user of
        User -> kvs:put(Poll#poll{title = Title});
        _ -> ok
    end.

alts(User, Poll, Alts, #vote{ballot = Ballot}) ->
    Alts2 = polls:user_alts(Alts, Ballot, usr:seed()),
    #panel{
        id = alts, body = [alt(Alt, V, polls:can_edit(User, Poll, Alt)) || {V, P, Alt} <- Alts2]
    }.

edit_panel(Poll, Vote, Alts) ->
    wf:wire(#api{name = vote}),
    User = usr:id(),
    #panel{
        class = [container, main],
        id = edit_panel,
        body = #element{
            html_tag = <<"form">>,
            data_fields = [{onsubmit, "voteSubmit(event);"}],
            body = [
                title(User, Poll),
                alts(User, Poll, Alts, Vote),
                add_alt_form(),
                vote_form(Vote#vote.name, Alts)
            ]
        }
    }.
%	body=#element{html_tag = }}.
% 	, body=[

% % ]}}.

name_list(L) ->
    I = usr:id(),
    L2 = lists:map(
        fun
            ({U, _, P}) when U == I -> {"<i>I</i>" ++ "", P};
            ({_, N, P}) -> {wf:hte(wf:to_list(N)) ++ "", P}
        end,
        L
    ),
    L3 = lists:map(
        fun
            ({S, P}) when P > 0 -> "<span class='upwote'>" ++ S ++ "</span>";
            ({S, _}) -> S
        end,
        L2
    ),
    string:join(L3, ", ").

li_class(Pos) when Pos < 1 -> looser;
li_class(_) -> upwoted.

sups([]) -> "";
sups(S) -> #span{class = supps, body = name_list(S)}.

result(Ids, Pos, Supps, Classes) ->
    Alts = [kvs:get(alt, Id) || Id <- Ids],
    R = [
        #li{
            class = Classes ++ [li_class(Pos)],
            body = [
                #span{class = vote, body = (Pos)},
                #panel{
                    class = text,
                    body = [
                        wf:hte(Alt#alt.text),
                        sups(dict:fetch(Alt#alt.id, Supps))
                    ]
                }
            ]
        }
     || {ok, Alt} <- Alts
    ].

results([]) ->
    [];
results([{Winners, Pw} | Other]) ->
    Supps = polls:supporters(poll_id()),
    O = [result(Ids, P, Supps, []) || {Ids, P} <- Other],
    result(Winners, Pw, Supps, [winner]) ++ O.

results() -> results(polls:result(poll_id())).

results_panel(Poll, Js_escape) ->
    #dtl{
        file = "results",
        js_escape = Js_escape,
        bindings = [
            {title, wf:html_encode(Poll#poll.title)},
            {results, results()},
            {poll_id, poll_id()},
            {vote_button, #button{
                id = send, class = [button], body = "change vote", postback = show_edit
            }},
            {is_temp, not usr:is_pers()}
        ]
    }.

poll_body(Poll, Alts, Js_escape) ->
    Vote = polls:get_vote(usr:id(), poll_id()),
    #panel{
        id = body,
        body = [
            view_common:top_bar(),
            case Vote#vote.ballot of
                [] -> edit_panel(Poll, Vote, Alts);
                _ -> results_panel(Poll, Js_escape)
            end
        ]
    }.

main() ->
    % attemt to localise, return t it later
    % {ok, L, _} = cowboy_req:parse_header(<<"accept-language">>, ?REQ, <<"en">>),
    case poll() of
        undefined ->
            view_404:main();
        Poll ->
            Alts = polls:alts(Poll#poll.id),
            Desc = string:join([wf:to_list(A#alt.text) || A <- Alts], ", "),
            view_common:page([
                {title, wf:html_encode(Poll#poll.title)},
                {description, wf:html_encode(Desc)},
                {body, poll_body(Poll, Alts, false)}
            ])
    end.

alt_event(Fun) ->
    Poll = poll(),
    AltId = wf:to_integer(wf:q(id)),
    case polls:get_alt(Poll, AltId) of
        undefined ->
            no;
        Alt ->
            case polls:can_edit(usr:id(), Poll, Alt) of
                true -> Fun(Poll, Alt);
                _ -> no
            end
    end.

event(init) ->
    Poll = poll(),
    Title = nitro:hte(Poll#poll.title),
    nitro:update(top, title_input(Title)),
    nitro:insert_bottom(bottom, add_alt_form()),
    nitro:insert_bottom(bottom, vote_form("denys", true));
event(add_alt) ->
    case filter:string(nitro:q(alt_text), 128, []) of
        [] ->
            no;
        T ->
            Alt = #alt{id = kvs:seq(alt, 1), user = usr:ensure(), text = T},
            kvs:append(Alt, "/poll/alts"),
            nitro:insert_bottom(alts, alt(Alt, 0, true)),
            nitro:wire("clearAltForm();")
    end;
event(del_alt) ->
    alt_event(fun(Poll, Alt) ->
        kvs:put(Alt#alt{hidden = true}),
        view_common:wf_update(?ALT_ID(Alt, panel), restore_alt(Alt))
    end);
event(edit_alt) ->
    alt_event(fun(Poll, Alt) ->
        Id = ?ALT_ID(Alt, text),
        view_common:wf_update(Id, #panel{
            id = Id,
            body = [
                #textarea{id = ?ALT_ID(Alt, new), maxlength = 128, body = wf:hte(Alt#alt.text)},
                #panel{
                    class = edit_buttons,
                    body = [
                        alt_link(cancel_edit_alt, "cancel", Alt),
                        alt_link(update_alt, "save", Alt, [?ALT_ID(Alt, new)])
                    ]
                }
            ]
        })
    end);
event(cancel_edit_alt) ->
    alt_event(fun(Poll, Alt) ->
        view_common:wf_update(?ALT_ID(Alt, text), alt_text(Alt, true))
    end);
event(update_alt) ->
    alt_event(fun(Poll, Alt) ->
        Text = filter:string(wf:q(?ALT_ID(Alt, new)), 128, []),
        case Text of
            [] ->
                no;
            T ->
                New = Alt#alt{user = usr:id(), text = T},
                kvs:put(New),
                view_common:wf_update(?ALT_ID(Alt, text), alt_text(New, true))
        end
    end);
event(restore_alt) ->
    alt_event(fun(Poll, Alt) ->
        kvs:put(Alt#alt{hidden = false}),
        V = polls:get_vote(usr:id(), poll_id()),
        B = maps:from_list(V#vote.ballot),
        view_common:wf_update(?ALT_ID(Alt, ""), alt(Alt, maps:get(Alt#alt.id, B, 0), true))
    end);
event(show_edit) ->
    Poll = poll(),
    Alts = polls:alts(Poll#poll.id),
    Vote = polls:get_vote(usr:id(), poll_id()),
    view_common:wf_update(results_panel, edit_panel(Poll, Vote, Alts));
event(view_results) ->
    view_common:wf_update(edit_panel, results_panel(poll(), true)),
    wf:wire("FB.XFBML.parse();");
event(Unk) ->
    io:format("Unknown event: ~p~n", [Unk]).

prepare_prefs(Votes) ->
    % to pairs of ints
    wf:warning(Votes),
    P1 = [{wf:to_integer(A), filter:int(V, -3, 7, 0)} || [A, V] <- Votes],
    % remove not incorrect alt ids and zero prefs,
    Alts = polls:alt_ids(poll_id()),
    P2 = lists:filter(fun({A, V}) -> (V /= 0) and lists:member(A, Alts) end, P1),
    lists:reverse(lists:keysort(2, P2)).

api_event(fb_login, Token, _) ->
    U = usr:fb_login(Token),
    Poll = poll(),
    Alts = polls:alts(Poll#poll.id),
    view_common:wf_update(body, poll_body(Poll, Alts, true));
api_event(vote, Data, _) ->
    Props = jsone:decode(list_to_binary(Data), [{object_format, proplist}]),

    Title = filter:string(get_value(<<"title">>, Props), ?TITLE_MAX_LENGTH, <<"poll">>),
    update_title(poll(), Title),

    Prefs = prepare_prefs(get_value(<<"votes">>, Props)),

    User = usr:ensure(),
    Name = filter:string(get_value(<<"name">>, Props), 32, <<"anon">>),
    polls:put_vote(User, poll_id(), Name, Prefs),
    event(view_results),
    view_common:ga_event(poll, vote).

get_value(Key, Props) -> proplists:get_value(Key, Props, []).

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

badge_class(I) ->
    if
        I > 0 -> 'bg-success';
        I < 0 -> 'bg-danger';
        I == 0 -> ''
    end.

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
                        postback = {edit_alt, 1}
                    },
                    #p{
                        class = 'card-text',
                        body = [
                            polls:text(Alt),
                            #br{},
                            #span{class = 'small text-muted', body = nitro:hte(polls:name(Alt))}
                        ]
                    }
                ]
            },
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
                            class = 'col-10',
                            body = #range{
                                id = ?ALT_ID(Alt, badge),
                                value = Vote,
                                min = -3,
                                max = 7,
                                class = 'form-range',
                                data_fields = [{oninput, 'onSliderChange(this)'}]
                            }
                        }
                    ]
                }
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
                    class = 'btn btn-primary btn-sm',
                    body = ?T("Add"),
                    postback = add_alt,
                    source = [alt_text]
                }
            }
        ]
    }.

vote_form(Name, IsNew) ->
    #panel{
        class = 'mt-4',
        body = [
            #label{
                class = 'form-label',
                body = [?T("Your name"), " <small>", ?T("(required)"), "</small>"]
            },
            #textbox{
                id = name,
                class = 'form-control',
                maxlength = ?NAME_MAX_LENGTH,
                value = nitro:hte(Name),
                onchange = 'validateName()'
            },
            #panel{
                class = 'd-grid gap-2 mt-4',
                body =
                    case IsNew of
                        true ->
                            #submit{class = 'btn btn-success', body = ?T("Create poll")};
                        _ ->
                            [
                                #submit{class = 'btn btn-success', body = ?T("Vote")},
                                #button{
                                    class = 'btn btn-outline-secondary',
                                    body = ?T("View results"),
                                    postback = view_results
                                }
                            ]
                    end
            }
        ]
    }.
