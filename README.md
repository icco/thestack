# theStack!

A simple app to help you remember your ideas. Runs locally thanks to sinatra.

Orginally inspired by [the data structure][1]... but let's be honest, it is entirely unrelated now.

## General Concept

The general idea is a pile of notes and ideas that are searchable.

## Installation 

 * if you are on Debian, make sure you install `libsqlite3-dev`, `ruby-dev` and `libopenssl-ruby`
 * You need to install all of the gems listed in .gems.
   * `less`, `sinatra`, `rdiscount`, `sequel`, `sqlite3-ruby`, `differ`
 * This works better on ruby 1.8, but should work in 1.9.2 as well.
 * to launch, run `rake`.
 * point your browser at <http://localhost:4567>

 [1]: http://en.wikipedia.org/wiki/Stack_(data_structure)
 [2]: http://heroku.com/
 [3]: http://www.sinatrarb.com/
 [4]: http://github.com/sinatra/heroku-sinatra-app

## Developer Notes

I am incredibly forgetful. So here is a list of references for when I'm trying to do productive stuff.

 * [Sequel Cheat Sheet](http://sequel.rubyforge.org/rdoc/files/doc/cheat_sheet_rdoc.html)
 * [SQLite](http://www.sqlite.org/sqlite.html)
 * [Markdown Dingus](http://daringfireball.net/projects/markdown/dingus)

## TODO

This list doesn't have any real order to it, just stuff I want to get done at some point. 

 * tag posts
 * Test on mobile devices
 * add HTML5 Offline support / Syncing
   * Maybe instead create syncing with Amazon's SDB.
   * Or maybe a heroku site that's purely an API for syncing.
 * upload image to third party image host
   * could be basically a type of children
 * related posts
   * LSI, like Jekyll...?
 * Add support for adding children
 * Caching
   * even just session caching. The number of repeat queries is just silly.
 * Maybe make it hosted? 
   * Add user support
      * would the entire site be private for that user?
