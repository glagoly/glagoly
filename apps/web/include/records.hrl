-include_lib("kvs/include/kvs.hrl").

-record(login, {creds, user}).
-record(poll, {id, user, title}).
-record(alt, {?ITERATOR(feed), user, text, hidden}).
-record(vote, {?ITERATOR(feed), user_poll, name = [], ballot = []}).
-record(my_poll, {?ITERATOR(feed), user_poll}).
-record(poll_seen, {user_poll, alt = 0, vote = 0}).
