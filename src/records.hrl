-define(NOW, erlang:system_time(second)).

-record(login, {creds, user}).
-record(poll, {id, user, title, date = ?NOW}).
-record(alt, {id, next, prev, poll, user, text, status = ok}).
-record(vote, {id = undefined, next, prev, name = [], ballot = [], date = ?NOW}).
-record(my_poll, {id, next, prev}).
