-module(view_policy).
-compile(export_all).
-include_lib("n2o/include/n2o.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("web.hrl").

main() ->
    view_common:page([
        {title, "my polls"},
        {body, #panel{
            id = body,
            body = [
                view_common:top_bar(),
                #dtl{file = "policy"}
            ]
        }}
    ]).
