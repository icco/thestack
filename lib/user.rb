class User < Sequel::Model(:users)
   def initialize
      db_options = {
         :server              => 'sdb.amazonaws.com',
         :port                => 443,
         :protocol            => 'https',
         :signature_version   => '1',
         :multi_thread        => true,
         :nil_representation  => ''
      }

      @db =  sdb = RightAws::SdbInterface.new(self.accesskey, self.secretkey, db_options)
   end

   def db
      return @db
   end

   def User.auth user, pw
      hash = User.hash_pw pw
      User.find(:password => hash, :username => user)
   end

   def User.hash_pw pw
      return pw
   end
end
