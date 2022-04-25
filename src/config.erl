-module(config).

-export([metainfo/0]).
-include_lib("kvs/include/metainfo.hrl").
-include_lib("kvs/include/kvs.hrl").
-include_lib("records.hrl").

metainfo() -> #schema{name = glagoly, tables = tables()}.

tables() -> [
    #table{name = login, fields = record_info(fields, login)},
    #table{name = poll, fields = record_info(fields, poll)},
    #table{name = alt, fields = record_info(fields, alt), keys = [user]},
    #table{name = vote, fields = record_info(fields, vote)},
    #table{name = my_poll, fields = record_info(fields, my_poll)}
].
