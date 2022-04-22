
-record(login, {creds, user}).
-record(poll, {id, user, title}).
-record(alt, {id, next, prev, user, text, hidden}).
-record(vote, {id, next, prev, user_poll, name = [], ballot = []}).
-record(my_poll, {id, next, prev, user_poll}).
