# glagoly - online voting platform

## Local run

Start the app (localhost:8001/app/index.html):

    ./rebar3 shell
    c(view_index).

### Build front js
    
    npm i
    npm run js

## Update on prod
    
    cd /var/www/glagoly/

    rebar3 release
    _build/default/rel/prod/bin/prod daemon

    CTRL-D 
