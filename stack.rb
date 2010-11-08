#!/usr/bin/env ruby
# An app for saving ideas. Uses Erb and Less for theming.

require 'rubygems'
require 'sinatra'
require 'less'
require 'sequel'
require 'rdiscount'

# Always run at launch
configure do
   set :sessions, true
   DB = Sequel.connect('sqlite://theStack.db')
end

get '/' do
   erb :index, :locals => {:posts => Post.getPosts}
end

post '/' do
   p params.inspect

   # I really need to validate this...
   text = params[:text]
   title = params[:title]
   parent = params[:parent].nil? ? 0 : params[:parent].to_i

   # Build and save the object
   d = Post.new 
   d.text = text
   d.title = title
   d.date = Time.now.to_i
   d.parent = parent
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
   out = "<pre>\n"
   ENV.to_hash.each_pair {|a, b| out += "#{a}: #{b}\n" }
   out += "</pre>\n"

   out
end

# So normall we would put this in a serperate file. But we are trying to keep
# this all compact and what not.
#
# Anyway, this deals with the posts. It's definition is built off of what is in
# the DB.
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

   def blurb
      return self.text.slice(0..100)
   end

   def children
      return @children
   end

   def children= x
      @children = x
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
         p.parent = row[:parent]
         p.children = DB[:posts][:parent => id]

         return p
      end
   end

   def Post.getPosts
      Post.order(:date.desc).limit(10)
   end
end

