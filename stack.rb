#!/usr/bin/env ruby
# An app for saving ideas. Uses Erb and Less for theming.

# The libs we require
require 'rubygems'
require 'sinatra'       # Webserver
require 'less'          # CSS+
require 'sequel'        # super easy DBO
require 'rdiscount'     # Markdown processor
require 'differ'        # https://github.com/pvande/differ
require 'logger'        # ...

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

   Differ.format = :html
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

get '/history/:id' do
   p = Post.build params[:id]

   if p
      erb :history, :locals => {
         :post => p,
         :posts => p.revisions
      }
   else 
      status 404
      "Not found"
   end
end

get '/edit/:id' do
   p = Post.build params[:id]

   if p
      erb :edit, :locals => { :post => p }
   else 
      status 404
      "Not found"
   end
end

post '/edit/:id' do
   p = Post.build params[:id]

   if p
      p.text = params[:text]
      p.title = params[:title]
      p.date = Time.now.to_i
      p.save

      redirect "/view/#{p.postid}"
   else 
      status 404
      "Not found"
   end
end

post '/search' do
   cleaned = CGI::escape params[:string].strip
   redirect "/search/#{cleaned}"
end

get '/search/:string' do
   query = CGI::unescape params[:string]
   posts = Post::search(query)
   p query
   erb :search, :locals => { 
      :posts => posts, 
      :search => query 
   }
end

get '/style.css' do
   content_type 'text/css', :charset => 'utf-8'
   less :style
end

get %r{/(view|edit|history|search)/?} do
   redirect '/'
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

# So normally we would put this in a serperate file. But we are being lazy
#
# Anyway, this deals with the posts. It's definition is built off of what is in
# the DB.
class Post < Sequel::Model(:posts)
   def to_s
      inspect
   end

   # Needs to create revisions on save.
   def save
      super

      PostRevision.build self
   end

   # http://sequel.rubyforge.org/rdoc/files/doc/validations_rdoc.html
   def validate
      super
   end

   # Makes the classic "x thing ago"
   #
   # TODO: deal with yesterday, words for values less than ten
   def nice_date
      distance = self.date ? Time.now.to_i - self.date : 0

      out = case distance
            when 0 .. 59 then "#{distance} seconds ago"
            when 60 .. (60*60) then "#{distance/60} minutes ago"
            when (60*60) .. (60*60*24) then "#{distance/(60*60)} hours ago"
            when (60*60*24) .. (60*60*24*30) then "#{distance/((60*60)*24)} days ago"
            else Time.at(self.date).strftime("%m/%d/%Y")
         end

      out.sub(/^1 (\w+)s ago$/, '1 \1 ago')
   end

   def title
      if super.empty? then "Post ##{self.postid}" else super end
   end

   def nice_text
      md = RDiscount.new(self.text, :smart)
      return md.to_html
   end

   # strips out html of rendered version and returns 100 characters
   def blurb
      post = self.text.length > 100 ? '...' : ''
      return self.nice_text.gsub(/<\/?[^>]+?>/, '').delete("\n").slice(0..100) + post
   end

   # Gives a rough idea of how "big" this post is.
   def size 
      charPerKb = 128.to_f

      text_size = self.text.length.to_f/charPerKb 
      title_size = self.title.length.to_f/charPerKb 

      return "#{text_size + title_size} kb"
   end

   def children
      return Post.filter(:parent => self.postid)
   end

   def children?
      return self.children.count > 0
   end

   def revisions
      PostRevision.filter(:postid => self.postid).order(:revisionid.desc)
   end

   def Post.build id
      Post.find(:postid => id)
   end

   def Post.getPosts
      Post.order(:date.desc).limit(10)
   end

   # a very simple search
   def Post.search string
      Post.filter(:title.like("%#{string}%") | :text.like("%#{string}%"))
   end
end

# TODO: make a library to deal with ugly code duplication.
class PostRevision < Sequel::Model(:revisions)
   def diff_text
      previous = self.previous

      if previous
         diff = Differ.diff_by_word(self.text, previous.text)
      else
         diff = Differ.diff_by_word(self.text, "")
      end

      return diff
   end

   def diff_title
      previous = self.previous

      if previous
         diff = Differ.diff_by_word(self.title, previous.title)
      else
         diff = Differ.diff_by_word(self.title, "")
      end

      return diff
   end

   def nice_date
      distance = self.date ? Time.now.to_i - self.date : 0

      out = case distance
            when 0 .. 59 then "#{distance} seconds ago"
            when 60 .. (60*60) then "#{distance/60} minutes ago"
            when (60*60) .. (60*60*24) then "#{distance/(60*60)} hours ago"
            when (60*60*24) .. (60*60*24*30) then "#{distance/((60*60)*24)} days ago"
            else Time.at(self.date).strftime("%m/%d/%Y")
         end

      out.sub(/^1 (\w+)s ago$/, '1 \1 ago')
   end

   def previous
      PostRevision.filter(
         {:postid => self.postid} & (:revisionid < self.revisionid)
      ).order(:revisionid.desc).first
   end

   def PostRevision.build post
      pr = PostRevision.new
      pr.postid = post.postid
      pr.text = post.text
      pr.title = post.title
      pr.date = Time.now.to_i
      pr.parent = post.parent
      pr.save
   end
end
