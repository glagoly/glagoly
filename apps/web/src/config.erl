-module(config).
-compile(export_all).
-include_lib("kvs/include/metainfo.hrl").
-include_lib("kvs/include/kvs.hrl").
-include_lib("kvs/include/feed.hrl").
-include_lib("records.hrl").

metainfo() -> 
    #schema{name=glagoly,tables=[
      #table{name=login,fields=record_info(fields, login)},
      #table{name=poll,fields=record_info(fields, poll)},
      #table{name=alt,container=feed,fields=record_info(fields,alt)},
      #table{name=vote,container=feed,fields=record_info(fields,vote),keys=[user_poll]},
      #table{name=my_poll,container=feed,fields=record_info(fields,my_poll),keys=[user_poll]}
    ]}.

log_level() -> debug.

log_modules() -> %all.
  [
  %  kvs,
    create,
    vote_core,
    index,
    edit,
    filter,
    result,
    kvs,
    feed,
    usr,
    polls
  %  poll
 %   n2o_nitrogen,
  %  n2o_session,
   % doc,
    %index
  ].