#!/usr/bin/ruby1.8
# An app for saving ideas. Uses Erubris and Less for theming.

require 'rubygems'
require 'sinatra'
require 'less'
require 'sequel'
require 'rdiscount'

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
   erb :index, :locals => {:posts => Post.getPosts}
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
         :posts => Post.getPosts
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
      distance = self.date ? Time.now.to_i - self.date : 0

      case distance
         when 0 .. 59 then "#{distance} seconds ago"
         when 60 .. (3600-1) then  "#{distance/60} minutes ago"
         when 3600 .. (3600*24-1) then  "#{distance/360} hours ago"
         when (3600*24) .. (3600*24*30) then  "#{distance/(3600*24)} days ago"
         else Time.at(self.date).strftime("%m/%d/%Y")
      end
   end

   def title
      if super.empty? then "Post ##{self.postid}" else super end
   end

   def nice_text
      md = RDiscount.new(self.text, :smart)
      return md.to_html
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
      Post.order(:date.desc).limit(10)
   end
end

