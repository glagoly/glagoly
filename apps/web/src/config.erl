-module(config).
-compile(export_all).
-include_lib("kvs/include/metainfo.hrl").
-include_lib("kvs/include/kvs.hrl").

metainfo() -> 
    #schema{name=sample,tables=[]
    }.

log_level() -> info.

log_modules() -> 
  [
%    login,
    create
 %   n2o_nitrogen,
  %  n2o_session,
   % doc,
    %index
  ].