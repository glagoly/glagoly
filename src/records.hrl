-define(ID_LENGTH, 8).
-define(TITLE_MAX_LENGTH, 128).
-define(ALT_MAX_LENGTH, 128).
-define(NAME_MAX_LENGTH, 32).

-define(NOW, erlang:system_time(second)).
-define(POLL_OPTS, #{access => public}).

-record(login, {creds, user, data}).
-record(poll, {id, user, title, opts = ?POLL_OPTS, date = ?NOW}).
-record(alt, {id, next, prev, poll, user, text, status = ok}).
-record(vote, {id = undefined, next, prev, name = [], ballot = [], status = ok, date = ?NOW}).
-record(my_poll, {id, next, prev, opts}).
