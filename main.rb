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
   DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://thestack.db')
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

   redirect "/view/#{d.postid}";
end

get '/view/:id' do
   p = Post.build params[:id]
   erubis :view, :locals => {
      :post => p,
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


class Post < Sequel::Model(:posts)
   def before_create 
      super
      @date = Time.now.to_i
      @userid = 1
      @title = "fake title"

   end

   def Post.build id
      row = DB[:posts][:postid => id]
      p row.inspect

      p = Post.new
      p.date = row[:date]
      p.title = row[:title]
      p.postid = row[:postid]
      p.text = row[:text]
      p.userid = row[:userid]

      return p
   end

   def Post.getPosts
      list = DB[:posts].order(:date.desc).limit(10)
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

