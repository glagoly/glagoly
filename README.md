# glagoly - online voting platform

## Local run

Start the app (localhost:8001/app/index.html):

    ./rebar3 shell
    c(view_index).

### Build front js
    
    npm i
    npm run js

### Unit tests

    ./rebar3 eunit
    ./rebar3 eunit --module="filter_tests"

### Codestyle

    ./rebar3 fmt -w

## Update on prod
    
    sudo su # Important
    cd /var/www/glagoly/

Start:

    rebar3 release
    _build/default/rel/prod/bin/prod daemon

Attach:
    
    _build/default/rel/prod/bin/prod daemon_attach
    # CTRL-D - detach from console

Update:

    git pull
    rebar3 compile
    _build/default/rel/prod/bin/prod restart

