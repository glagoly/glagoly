# glagoly - online voting platform

## To build localy

Install npm or update npm to latest version:

    sudo npm install npm -g

After you get them insall npm dependencies:
    
    npm install

Insall bower globally:

    npm install -g bower
     
Install bower dependencies:

    bower install

Run gulp:

    npm run start

## Build front

    gulp build --production

## On prod
    
    make console
    make start

## requirments

    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb

    sudo apt-get update

    sudo apt-get install make inotify-tools esl-erlang

