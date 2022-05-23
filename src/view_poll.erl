-module(view_poll).
-export([event/1, api_event/3]).

-include_lib("n2o/include/n2o.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("records.hrl").
-include_lib("web.hrl").

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

title(User, Poll) ->
    T = wf:html_encode(Poll#poll.title).

update_title(Poll, Title) ->
    User = usr:id(),
    case Poll#poll.user of
        User -> kvs:put(Poll#poll{title = Title});
        _ -> ok
    end.

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
                % alts(User, Poll, Alts, Vote),
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

event(init) ->
    Poll = poll(),
    io:format("ID: ~p~n", [usr:id()]),
    Title = nitro:hte(Poll#poll.title),
    nitro:update(top, view:title_input(Title)),
    nitro:update(alts, alts_panel()),
    nitro:insert_bottom(bottom, add_alt_form()),
    nitro:insert_bottom(bottom, vote_form("denys", true));
event(view_vote) ->
    Poll = poll(),
    Alts = polls:alts(Poll#poll.id),
    Vote = polls:get_vote(usr:id(), poll_id()),
    view_common:wf_update(results_panel, edit_panel(Poll, Vote, Alts));
event(view_results) ->
    Poll = poll(),
    nitro:update(top, title(polls:title(Poll))),
    Result = polls:result(poll_id()),
    nitro:update(alts, results_panel(Result));
event(add_alt) ->
    case filter:string(nitro:q(alt_text), 128, []) of
        [] ->
            no;
        Text ->
            Alt = polls:append_alt(poll_id(), Text, usr:ensure()),
            nitro:insert_bottom(alts, alt(Alt, 0, true)),
            nitro:wire(#jq{target = alt_text, property = value, right = ""})
    end;
% event(del_alt) ->
%     alt_event(fun(Poll, Alt) ->
%         kvs:put(Alt#alt{hidden = true}),
%         view_common:wf_update(?ALT_ID(Alt, panel), restore_alt(Alt))
%     end);
event({alt, Op, Id}) ->
    Poll = poll(),
    Alt = polls:get_alt(Poll, Id),
    true = polls:can_edit(usr:id(), Poll, Alt),
    nitro:update(?ALT_ID(Alt, panel), alt_event(Op, Alt));
% event(cancel_edit_alt) ->
%     alt_event(fun(Poll, Alt) ->
%         view_common:wf_update(?ALT_ID(Alt, text), alt_text(Alt, true))
%     end);
% event(update_alt) ->
%     alt_event(fun(Poll, Alt) ->
%         Text = filter:string(wf:q(?ALT_ID(Alt, new)), 128, []),
%         case Text of
%             [] ->
%                 no;
%             T ->
%                 New = Alt#alt{user = usr:id(), text = T},
%                 kvs:put(New),
%                 view_common:wf_update(?ALT_ID(Alt, text), alt_text(New, true))
%         end
%     end);
% event(restore_alt) ->
%     alt_event(fun(Poll, Alt) ->
%         kvs:put(Alt#alt{hidden = false}),
%         V = polls:get_vote(usr:id(), poll_id()),
%         B = maps:from_list(V#vote.ballot),
%         view_common:wf_update(?ALT_ID(Alt, ""), alt(Alt, maps:get(Alt#alt.id, B, 0), true))
%     end);

event(Unk) ->
    io:format("Unknown event: ~p~n", [Unk]).

alt_event(edit, Alt) -> edit_alt_form(Alt);
alt_event(cancel_edit, Alt) -> alt(Alt, polls:vote(usr:id(), Alt), true);
alt_event(save, Alt) -> alt(Alt, polls:vote(usr:id(), Alt), true);
alt_event(delete, Alt) -> restore_alt(Alt);
alt_event(restore, Alt) -> alt(Alt, polls:vote(usr:id(), Alt), true).

filter_votes(Votes) ->
    % to pairs of ints
    P1 = [{nitro:to_list(A), filter:in_range(binary_to_integer(V), -3, 7)} || [A, V] <- Votes],
    lists:filter(fun({A, V}) -> (V /= 0) end, P1).

api_event(fb_login, Token, _) ->
    U = usr:fb_login(Token),
    Poll = poll(),
    Alts = polls:alts(Poll#poll.id),
    view_common:wf_update(body, poll_body(Poll, Alts, true));
api_event(vote, Data, _) ->
    Props = jsone:decode(list_to_binary(Data)),
    % io:format("ID: ~p~n", [Props#{<<"votes">>}]),

    % Title = filter:string(get_value(<<"title">>, Props), ?TITLE_MAX_LENGTH, <<"poll">>),
    % update_title(poll(), Title),

    Name = filter:string(maps:get(<<"name">>, Props), ?NAME_MAX_LENGTH, <<"anon">>),
    Votes = filter_votes(maps:get(<<"votes">>, Props)),
    io:format("ID: ~p~n", [Votes]),

    User = usr:ensure(),

    polls:put_vote(User, poll_id(), Name, Votes),
    event(view_results).

%%%=============================================================================
%%% HTML Components
%%%=============================================================================

title(Title) ->
    #h1{id = top, body = nitro:hte(Title), class = 'display-5 mb-3 mt-3'}.

badge_class(I) ->
    if
        I > 0 -> 'bg-success';
        I < 0 -> 'bg-danger';
        I == 0 -> ''
    end.

results_panel(Result) ->
    Poll = poll(),
    Voters = polls:voters(poll_id()),
    #panel{
        id = alts,
        body = [
            result(polls:get_alt(Poll, AltId), V, maps:get(AltId, Voters, []))
         || {V, AltId} <- Result
        ]
    }.

voter({Name, Vote}) -> #span{body = [nitro:hte(Name), " ", filter:pretty_int(Vote)]}.

result(Alt, Vote, Voters) ->
    #panel{
        id = ?ALT_ID(Alt, panel),
        class = 'card mb-3',
        body = [
            #panel{
                class = 'card-body',
                body = #p{
                    class = 'card-text',
                    body = [
                        polls:text(Alt),
                        #br{},
                        #span{class = 'small text-muted', body = nitro:hte(polls:name(Alt))}
                    ]
                }
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
                            body = lists:join(", ", [voter(V) || V <- Voters])
                        }
                    ]
                }
            }
        ]
    }.

alts_panel() ->
    Poll = poll(),
    Alts = polls:user_alts(usr:id(), poll_id(), usr:seed()),
    #panel{
        id = alts, body = [alt(Alt, V, polls:can_edit(usr:id(), Poll, Alt)) || {V, Alt} <- Alts]
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
                                id = ?ALT_ID(Alt, slider),
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
            ?T(" deleted alterntive.")
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
                        class = 'btn btn-primary btn-sm ms-3',
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
                    class = 'btn btn-primary btn-sm',
                    body = ?T("Add"),
                    postback = add_alt,
                    source = [alt_text]
                }
            }
        ]
    }.

vote_form(Name, IsNew) ->
    nitro:wire(#api{name = vote}),
    [
        % Not Great, Not Terrible
        <<"<form class='mt-4' novalidate onsubmit='voteSubmit(event); return false;'>">>,
        #label{
            class = 'form-label',
            body = [?T("Your name"), " <small>", ?T("(required)"), "</small>"]
        },
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
            class = 'd-grid gap-2 mt-4',
            body =
                case IsNew of
                    true ->
                        #submit{class = [btn, 'btn-success'], body = ?T("Create poll"), click = []};
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
        },
        <<"</form>">>
    ].
