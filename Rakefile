require "rubygems"
require 'rake/clean'
CLEAN.include("*.db")

# Define the Database.
DB_CONST = "theStack.db"

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
	DB.create_table! :posts do
		primary_key :postid
		Text :text
		String :title, :default => ""
		Integer :date, :default => 0
		Integer :parent, :default => 0
	end

	DB.create_table! :revisions do
		primary_key :revisionid
		Text :text
		String :title, :default => ""
		Integer :date, :default => 0
		Integer :parent, :default => 0
      foreign_key(:postid, :posts)
	end

	puts "Database built."
end

desc "Fill the DB with test data."
task :test => [:clean, :db] do
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

      (0..15).each {|y|
         sleep 1
         p.title = Faker::Lorem.sentence
         p.text = Faker::Lorem.paragraphs
         p.date = Time.now.to_i
         p.save
         print "."
         STDOUT.flush
      }

   }

   puts "Data Generation Finished."
end
