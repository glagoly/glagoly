-module(web).
-behaviour(supervisor).
-behaviour(application).
-export([init/1, start/2, stop/1, main/1]).
-compile(export_all).

main(A)    -> mad_repl:sh(A).
start(_,_) -> supervisor:start_link({local,web},web,[]).
stop(_)    -> ok.
init([])   -> case cowboy:start_http(http,3,port(),env()) of
                   {ok, _}   -> ok;
                   {error,_} -> halt(abort,[]) end, sup().

sup()    -> { ok, { { one_for_one, 5, 100 }, [] } }.
env()    -> [ { env, [ { dispatch, points() } ] } ].
static() ->   { dir, "apps/web/priv/static", mime() }.
n2o()    ->   { dir, "deps/n2o/priv", mime() }.
mime()   -> [ { mimetypes, cow_mimetypes, all   } ].
port()   -> [ { port, wf:config(n2o,port,8001)  } ].
points() -> cowboy_router:compile([{'_', [
			  { "/favicon.ico",  cowboy_static, {file, "apps/web/priv/static/favicon.ico"}},
			  { "/apple-touch-icon.png",  cowboy_static, {file, "apps/web/priv/static/apple-touch-icon.png"}},
			  { "/static/[...]", n2o_static, static() },
              { "/static/[...]", n2o_static, static() },
              { "/n2o/[...]",    n2o_static, n2o()    },
              { "/ws/[...]",     n2o_stream, []       },
              { '_',             n2o_cowboy, []       }]}]).

log_modules() -> [n2o_client,n2o_nitrogen,n2o_stream,wf_convert].
