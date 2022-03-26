# glagoly - online voting platform

## Requirments

Install npm or update npm to latest version:

    sudo npm install npm -g

After you get them insall npm dependencies:
    
    npm i

Start the app on localhost:7001:

    npm run start

Prerequirements:

    sudo apt install inotify-tools

## Build front

    npm run build

## On prod
    
    cd /var/www/html/glagoly/
    make console
    make start

## requirments

    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb

    sudo apt-get update

    sudo apt-get install make inotify-tools esl-erlang

