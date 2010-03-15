# An app for saving ideas. Uses Erubris and Less for theming.

require 'rubygems'
require 'sinatra'
require 'less'
require 'erubis'

configure :production do
   # Configure stuff here you'll want to
   # only be run at Heroku at boot

   # TIP:  You can get you database information
   #       from ENV['DATABASE_URI'] (see /env route below)
end

# Quick test
get '/' do
   erubis :index
end

get '/style.css' do
   content_type 'text/css', :charset => 'utf-8'
   less :style
end


# TODO: Delete...
get '/env' do
  ENV.inspect
end

