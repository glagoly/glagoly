-include_lib("kvs/include/kvs.hrl").

-record(poll, {id, title}).
-record(share, {id, poll_id}).
-record(alternative, {?ITERATOR(feed), text}).
-record(vote, {?ITERATOR(feed), votes}).