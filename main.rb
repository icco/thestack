# You'll need to require these if you
# want to develop while running with ruby.
# The config/rackup.ru requires these as well
# for it's own reasons.
#
# $ ruby main.rb
#
require 'rubygems'
require 'sinatra'

configure :production do
   # Configure stuff here you'll want to
   # only be run at Heroku at boot

   # TIP:  You can get you database information
   #       from ENV['DATABASE_URI'] (see /env route below)
end

# Quick test
get '/' do
     "Congradulations!
        You're running a Sinatra application on Heroku!"
end

# TODO: Delete...
get '/env' do
  ENV.inspect
end

