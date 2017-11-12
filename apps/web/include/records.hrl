-include_lib("kvs/include/kvs.hrl").

-record(poll, {id, user, title}).
-record(alt, {?ITERATOR(feed), user, text}).
-record(vote, {?ITERATOR(feed), user_poll, name = [], ballot = []}).
