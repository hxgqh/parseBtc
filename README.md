parseBtc
========

This is an personal repo.

Installation
    1. Ubuntu 13.04
        a. sudo apt-get update
        b. sudo apt-get install ruby rubygems
        c. sudo gem install nokogiri

Usage：
    1. Get device information from web
    ruby main.rb -g -c conf.txt     #If you need to run this script repeatedly, please write this line to crontab.

    2. Set device parameters
    ruby main.rb -s -c conf.txt     #We seldom set devices' parameters. If you need to do this, please be careful.