require "rubygems"

# Import in official clean and clobber tasks
require 'rake/clean'
CLEAN.include("tmp/*")

# Define the Database.
DB_CONST = "tmp/theStack.db"

task :default => [:run]

desc "Launch the app."
task :run do
   Rake::Task[:db].invoke if !File.exists? DB_CONST

   system './stack.rb'
end

desc "Launch the app with shotgun."
task :shotgun do
   # We do this to make sure you have shotgun
   require "shotgun"

   Rake::Task[:db].invoke if !File.exists? DB_CONST

   system 'shotgun config.ru'
end

desc "Create local db."
task :db do
   require "sequel"

   DB = Sequel.connect("sqlite://#{DB_CONST}")
   p DB
   DB.create_table! :users do
      primary_key :userid
      String   :username,  :default => ""
      String   :password,  :default => ""
      String   :accesskey, :default => ""
      String   :secretkey, :default => ""
      DateTime :joindate
   end

   puts "Database built."
end

desc "Fill the DB with test data."
task :test => [:clean, :db] do
   return # not rewritten since we switched database systems.

   require 'faker' # http://faker.rubyforge.org/
   require 'stack'

   (0..25).each {|x|
      p = Post.new
      p.title = Faker::Lorem.sentence
      p.text = Faker::Lorem.paragraphs
      p.date = Time.now.to_i
      p.save

      print "-"
      STDOUT.flush

      (0..5).each {|y|
         p.title = Faker::Lorem.sentence
         p.text = Faker::Lorem.paragraphs
         p.date = Time.now.to_i
         p.save
         print "."
         STDOUT.flush
      }

      p.add_tag "generated"
      p.save
   }

   # Tests from http://six.pairlist.net/pipermail/markdown-discuss/2004-December/000909.html
   Dir.glob("tests/*.t*").each {|fname|
      p = Post.new
      p.title = fname
      p.text = IO.read fname
      p.date = Time.now.to_i
      p.add_tag "markdown"
      p.save

      print "-"
      STDOUT.flush
   }

   puts " Data Generation Finished."
end
