-include_lib("kvs/include/kvs.hrl").

-record(poll, {id, user, title}).
-record(alt, {?ITERATOR(feed), user, text}).
-record(ballot, {?ITERATOR(feed), user, name, prefs}).
-record(user_ballot, {id, ballot}).