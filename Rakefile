require "rubygems"

task :default => [:run]

desc "Launch the app."
task :run do
   Rake::Task[:db].invoke if !File.exists? "thestack.db"

   exec './stack.rb'
end

desc "Create local db."
task :db do
   require "sequel"

	DB = Sequel.connect('sqlite://thestack.db')
	DB.create_table! :posts do
		primary_key :postid
		Text :text
		String :title, :default => ""
		Integer :date, :default => 0
		Integer :parent, :default => 0
	end

	puts "Database built."
end

desc "Run test suite."
task :test do
	puts <<-WHOA

      Whoa there, cowboy. Let's not get hasty.
      I mean, who seriously writes tests these days?

   WHOA
end

desc "Gets us back to a fresh install."
task :clean do
   FileUtils.rm Dir.glob('*.db')
end
