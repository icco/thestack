#!/usr/bin/ruby1.8
# An app for saving ideas. Uses Erubris and Less for theming.

require 'rubygems'
require 'sinatra'
require 'erubis'
require 'less'
require 'sequel'

# Always run at launch
configure do
   set :sessions, true
end

configure :production do
   # Configure stuff here you'll want to
   # only be run at Heroku at boot
end

get '/' do
   erubis :index, :locals => {:posts => Post.getPosts}
end

post '/' do
   d = Post.new 
   d.text = params[:text]
   d.save
   erubis :view, :locals => {
      :post => d,
      :posts => Post.getPosts
   }
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

def getDB
   Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://thestack.db')
end

class Post
   attr_accessor :text, :title, :date, :userid, :postid

   def initialize
      @title = "fake title"
      @userid = 1
      @date = 0
      @text = ""
      @postid = -1
   end

   def save
      @date = Time.now.to_i

      db = getDB
      data = db[:posts]
      data.insert(
         :text => @text,
         :date => @date,
         :title => @title
      )
   end

   def to_s
      inspect
   end

   def inspect
      {"postid" => @postid,
         "text" => @text,
         "title" => @title,
         "date" => @date,
         "userid" => @userid,
      }.inspect
   end

   def Post.getPosts
      list = getDB[:posts].order(:date.desc).limit(10)
      posts = []
      for row in list
         p = Post.new
         p.date = row[:date]
         p.title = row[:title]
         p.postid = row[:postid]
         p.text = row[:text]
         p.userid = row[:userid]

         posts.push(p)
      end

      return posts
   end
end

