-module(config).
-compile(export_all).
-include_lib("kvs/include/metainfo.hrl").
-include_lib("kvs/include/kvs.hrl").
-include_lib("kvs/include/feed.hrl").
-include_lib("records.hrl").

metainfo() -> 
    #schema{name=glagoly,tables=[
      #table{name=poll,fields=record_info(fields, poll)},
      #table{name=user_ballot,fields=record_info(fields, user_ballot)},
      #table{name=alt,container=feed,fields=record_info(fields,alt)},
      #table{name=ballot,container=feed,fields=record_info(fields,ballot)}
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
    user
  %  poll
 %   n2o_nitrogen,
  %  n2o_session,
   % doc,
    %index
  ].