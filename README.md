# theStack!

A simple app to help you remember your ideas. The two main constraints on this are that your data is always available, no matter the device, and that you personally own the data. Imagine a stack of notes that sits in your pocket, but you need a pair of glasses to read, or something like that. The analogy kind of fails, I know.

Orginally inspired by [the data structure][1]... but let's be honest, it is entirely unrelated now.

## Heroku and SimpleDB

I rewrote large portions of this app so I could host the app and deal with all of the icky stuff, but still allow users to own their own data (and pay for it too, I'm broke). The app is still very alpha and in no way secure, but it should work.

## Installation 

 * if you are on Debian, make sure you install `libsqlite3-dev`, `ruby-dev` and `libopenssl-ruby`
 * You need to install all of the gems listed in .gems.
   * `less`, `sinatra`, `rdiscount`, `sequel`, `sqlite3-ruby`, `differ`, `right_aws`
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
 * [SDB Pricing Example](http://aws.amazon.com/simpledb/#machine-utilization-example)
 * [Right AWS Docs](http://rightscale.rubyforge.org/right_aws_gem_doc/classes/RightAws/SdbInterface.html)

## TODO

This list doesn't have any real order to it, just stuff I want to get done at some point. 

 * upload image to third party image host
   * could be basically a type of children
 * related posts
   * LSI, like Jekyll...?
 * Add support for adding children
 * Caching
   * even just session caching. The number of repeat queries is just silly.
 * Deal with mobile users. - mobile style sheet
 * Add verification on login and signup
 * add safe failover if amazon auth keys are wrong
 * make profile editable.

