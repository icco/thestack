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
require 'time'          # Monkey patching for 1.9.2

# Always run at launch
configure do
   set :sessions, true
   DB = Sequel.connect("sqlite://tmp/theStack.db")

   # Print all queries to stdout
   dblogger = Logger.new(STDOUT)
   def dblogger.format_message(level, time, progname, msg)
      " DATABASE - - [#{time.strftime("%d/%b/%Y %H:%M:%S")}] #{msg}\n"
   end
   DB.loggers << dblogger

   Differ.format = :html
end

# Right now, this deals with Auth, I'm curious if there is a smarter way to do
# a white-list type auth scheme. 
before do
   # Alright plan for users
   # first, check if they are logged in
   needs_pw = /(login|signup|css|js|png|jpg)/
   if !session.has_key?('userid') && !request.path_info.match(needs_pw)
      session['previous'] = request.path_info
      redirect '/login'
   end
   # if not pass request.path_info and redirect them to login
   # else continue like nothing happened.
end

get '/login' do
   if session['userid']
      redirect '/'
   end

   erb :login 
end

post '/login' do
   userid = User::auth(params[:user_name], params[:password])
   if userid
      session['userid'] = userid

      # TODO: There has to be a better way to do this redirect bs.
      redirectto = session['previous'] ? session['previous'] : '/'
      session['previous'] = ""
      redirect redirectto
   else
      redirect '/login'
   end
end

get '/logout' do
   session.delete('userid')
   redirect '/login'
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
   d.tags = params[:tags]
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
      p.text  = params[:text]
      p.title = params[:title]
      p.tags  = params[:tags]
      p.date  = Time.now.to_i
      p.save

      redirect "/view/#{p.postid}"
   else
      status 404
      "Not found"
   end
end

get '/tag/:tagname' do
   tagname = params[:tagname] # This could be a security problem...
   posts = Post::tagsearch(tagname)
   erb :search, :locals => {
      :posts => posts,
      :search => ""
   }
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
   "I am running Sinatra version #{Sinatra::VERSION}."
end

# Dumps all of the environment variables.
#get '/env' do
#   out = "<pre>\n"
#   ENV.to_hash.each_pair {|a, b| out += "#{a}: #{b}\n" }
#   out += "</pre>\n"
#   out
#end
