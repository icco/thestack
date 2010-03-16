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
   d = Post.new params[:text]
   d.save
   erubis :view, :locals => {:post => d}
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

class Post 
   def initialize in_text
      @text = in_text
      @date = Time.now.to_i
   end

   def get_text 
      return @text
   end

   def set_text in_text
      @text = in_text
   end

   def save
      db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://thestack.db')
      data = db[:posts]
      data.insert(:text => @text, :date => @date)
   end
end

