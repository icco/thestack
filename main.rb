# An app for saving ideas. Uses Erubris and Less for theming.

require 'rubygems'
require 'sinatra'
require 'erubis'
require 'less'
require 'sequel'

# Always run at launch
configure do
   set :sessions, true
   DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://thestack.db')
   DB.drop_table :posts
   DB.create_table :posts do
      primary_key :postid
      Text :text
      integer :date
   end

end


configure :production do
   # Configure stuff here you'll want to
   # only be run at Heroku at boot
end

get '/' do
   erubis :index
end

post '/' do
   DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://thestack.db')
   data = DB[:posts]
   data.insert(:text => params['text'], :date => Time.now.to_i)
   erubis :view, :locals => {:hello => params['text']}
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

