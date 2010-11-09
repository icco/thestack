#!/usr/bin/env ruby
# An app for saving ideas. Uses Erb and Less for theming.

# The libs we require
require 'rubygems'
require 'sinatra'    # Webserver
require 'less'       # CSS+
require 'sequel'     # super easy DBO
require 'rdiscount'  # Markdown processor
require 'logger'     # ...

# Always run at launch
configure do
   set :sessions, true
   DB = Sequel.connect('sqlite://theStack.db')

   # Print all queries to stdout
   logger = Logger.new(STDOUT)
   def logger.format_message(level, time, progname, msg)
      " DATABASE - - [#{time.strftime("%d/%b/%Y %H:%M:%S")}] #{msg}\n"
   end 
   DB.loggers << logger
end

get '/' do
   erb :index, :locals => {:posts => Post.getPosts}
end

post '/' do
   # Validation is done by the Post object.
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

   # We've saved. Get the hell out of here.
   redirect "/view/#{d.postid}";
end

get '/view' do
   redirect '/'
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

get '/view/:id/raw' do
   p = Post.build params[:id]

   if p
      content_type 'text/plain', :charset => 'utf-8'
      p.text
   else 
      status 404
      "Not found"
   end
end

get '/search/:string' do
   query = params[:string]
   posts = Post::search(query)
   erb :search, :locals => { :posts => posts }
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

# So normally we would put this in a serperate file. But we are trying to keep
# this all compact and what not.
#
# Anyway, this deals with the posts. It's definition is built off of what is in
# the DB.
class Post < Sequel::Model(:posts)
   def to_s
      inspect
   end

   # Makes the classic "x thing ago"
   #
   # TODO: deal with 1 second, 1 minute, etc
   # TODO: deal with yesterday, words for values less than ten
   def nice_date
      distance = self.date ? Time.now.to_i - self.date : 0

      case distance
         when 0 .. 59 then "#{distance} seconds ago"
         when 60 .. (60*60) then "#{distance/60} minutes ago"
         when (60*60) .. (60*60*24) then "#{distance/(60*60)} hours ago"
         when (60*60*24) .. (60*60*24*30) then "#{distance/((60*60)*24)} days ago"
         else Time.at(self.date).strftime("%m/%d/%Y")
      end
   end

   def title
      if super.empty? then "Post ##{self.postid}" else super end
   end

   def nice_text
      md = RDiscount.new(CGI::unescapeHTML(self.text), :smart)
      return md.to_html
   end

   # strips out html of rendered version and returns 100 characters
   def blurb
      post = self.text.length > 100 ? '...' : ''
      return self.nice_text.gsub(/<\/?[^>]+?>/, '').delete("\n").slice(0..100) + post
   end

   def size 
      return "#{self.text.length/128} kb"
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

   def Post.search string
      Post.order(:date.desc).limit(10)
   end
end
