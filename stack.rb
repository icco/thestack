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
require 'guid'

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

   # Bring in our code after we configure.
   Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
end

# Right now, this deals with Auth, I'm curious if there is a smarter way to do
# a white-list type auth scheme.
before do
   # Alright plan for users
   # first, check if they are logged in
   no_pw = /(login|signup|css|js|png|jpg)/
   if !session.has_key?('userid') && !request.path_info.match(no_pw)
      session['previous'] = request.path_info
      redirect '/login'
   end
end

get '/login' do
   if session['userid']
      redirect '/'
   end

   erb :login
end

post '/login' do
   user = User::auth(params[:user_name], params[:password])
   if user
      session['userid'] = user.userid

      # TODO: There has to be a better way to do this redirect bs.
      redirectto = session['previous'] ? session['previous'] : '/'
      session.delete('previous')
      redirect redirectto
   else
      redirect '/login'
   end
end

get '/logout' do
   session.delete('userid')
   redirect '/login'
end

get '/signup' do
   if session['userid']
      redirect '/'
   else
      erb :signup
   end
end

post '/signup' do
   u = User.new
   u.accesskey = params[:access_key]
   u.secretkey = params[:secret_key]
   u.username  = params[:user_name] 
   u.password  = params[:password]
   u.joindate  = Time.now  
   u.save

   session['userid'] = u.userid

   redirect '/'
end

get '/' do
   erb :index, :locals => {:posts => Post.getPosts}
end

post '/' do
   # Validation is done by the Post object.
   text = params[:text]
   title = params[:title]

   # Build and save the object
   d = Post.new session['userid']
   d.text = text
   d.title = title
   d.date = Time.now.to_i
   d.tags = params[:tags]
   d.save

   # We've saved. Get the hell out of here.
   redirect "/view/#{d.postid}";
end

get '/view/:id' do
   p = Post.build params[:id], session['userid']

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
   p = Post.build params[:id], session['userid']

   if p
      content_type 'text/plain', :charset => 'utf-8'
      p.text
   else
      status 404
      "Not found"
   end
end

get '/history/:id' do
   p = Post.build params[:id], session['userid']

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
   p = Post.build params[:id], session['userid']

   if p
      erb :edit, :locals => { :post => p }
   else
      status 404
      "Not found"
   end
end

post '/edit/:id' do
   p = Post.build params[:id], session['userid']

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
