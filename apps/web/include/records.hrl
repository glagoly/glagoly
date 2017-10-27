-include_lib("kvs/include/kvs.hrl").

-record(poll, {id, user, title}).
-record(alt, {?ITERATOR(feed), text}).
-record(vote, {?ITERATOR(feed), name, prefs}).