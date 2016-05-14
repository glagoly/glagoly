-include_lib("kvs/include/kvs.hrl").

-record(poll, {id, title}).
-record(share, {id, poll_id}).