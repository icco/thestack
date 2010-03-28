require "rubygems"
require "sequel"

task :default => [:build]

task :build do
	# run sinatra locally...
end

task :deploy do
	# push to heroku
end

task :build_db do
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://thestack.db')
	DB.create_table! :posts do
		primary_key :postid
		Text :text
		String :title
		Integer :date
		Integer :userid
	end

	puts "Database built."
end

desc "Deploy to Heroku."
task :deploy do
	require 'heroku'
	require 'heroku/command'
	user, pass = File.read(File.expand_path("~/.heroku/credentials")).split("\n")
	heroku = Heroku::Client.new(user, pass)

	cmd = Heroku::Command::BaseWithApp.new([])
	remotes = cmd.git_remotes(File.dirname(__FILE__) + "/../..")

	remote, app = remotes.detect {|key, value| value == (ENV['APP'] || cmd.app)}

	if remote.nil?
		raise "Could not find a git remote for the '#{ENV['APP']}' app"
	end

	`git push #{remote} master`

	#heroku.rake(app, "db:migrate")
	heroku.rake(app, "build_db")
	heroku.restart(app)
end

task :test do
	puts "Whoa there, cowboy. Let's not get hasty."
end
