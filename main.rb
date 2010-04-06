#!/usr/bin/ruby1.8
# An app for saving ideas. Uses Erubris and Less for theming.

require 'rubygems'
require 'sinatra'
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
   erb :index, :locals => {:posts => Post.all}
end

post '/' do
   d = Post.new 
   d.text = params[:text]
   d.date = Time.now.to_i
   d.userid = 1
   d.save

   redirect "/view/#{d.postid}";
end

get '/view/:id' do
   p = Post.build params[:id]
   if p
      erb :view, :locals => {
         :post => p,
         :posts => Post.all
      }
   else 
      status 404
      "Not found"
   end
end

get '/error' do
   status 404
   puts "WE'VE HAD AN ERROR CAPTAIN!\n"
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
   def to_s
      inspect
   end

   def nice_date
      "date here..."
   end

   def Post.build id
      row = DB[:posts][:postid => id]

      if !row
         return nil
      else
         p = Post.new
         p.date = row[:date]
         p.title = row[:title]
         p.postid = row[:postid]
         p.text = row[:text]
         p.userid = row[:userid]

         return p
      end
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

