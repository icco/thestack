# theStack!

A simple todo app written in ruby that runs on [heroku][2] using [sinatra][3].

Based upon [the data structure][1]. 

## General Concept

The general idea is a pile of notes and ideas that are searchable.

## Installation 

 * if you are on Debian, make sure you install `libsqlite3-dev` and `libopenssl-ruby`
 * You need to install all of the gems listed in .gems
 * This works better on ruby 1.8, but should work in 1.9 as well
 * to launch local development server `rake build_db` then `./stack.rb`

 [1]: http://en.wikipedia.org/wiki/Stack_(data_structure)
 [2]: http://heroku.com/
 [3]: http://www.sinatrarb.com/
 [4]: http://github.com/sinatra/heroku-sinatra-app

