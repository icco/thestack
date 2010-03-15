# An app for saving ideas. Uses Erubris and Less for theming.

require 'rubygems'
require 'sinatra'
require 'erubis'
require 'less'

configure :production do
   # Configure stuff here you'll want to
   # only be run at Heroku at boot
end

get '/' do
   erubis :index
end

get '/style.css' do
   content_type 'text/css', :charset => 'utf-8'
   less :style
end

# TODO: Turn this into a template?
get '/about' do
   "I'm running version " + Sinatra::VERSION
end

# TODO: Delete...
get '/env' do
  ENV.inspect
end

