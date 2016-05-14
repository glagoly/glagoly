-module(config).
-compile(export_all).
-include_lib("kvs/include/metainfo.hrl").
-include_lib("kvs/include/kvs.hrl").
-include_lib("kvs/include/feed.hrl").
-include_lib("records.hrl").

metainfo() -> 
    #schema{name=glagoly,tables=[
      #table{name=poll,fields=record_info(fields,poll)}
    ]}.

log_level() -> info.

log_modules() -> 
  [
    kvs,
    create,
    poll
 %   n2o_nitrogen,
  %  n2o_session,
   % doc,
    %index
  ].