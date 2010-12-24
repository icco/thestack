require 'right_aws'

class User < Sequel::Model(:users)
   def aws_db
      if !@aws_db && self.accesskey && self.secretkey
         db_options = {
            :server              => 'sdb.amazonaws.com',
            :port                => 443,
            :protocol            => 'https',
            :signature_version   => '1',
            :multi_thread        => true,
            :nil_representation  => ''
         }

         @aws_db = RightAws::SdbInterface.new(self.accesskey, self.secretkey, db_options)
      end

      return @aws_db
   end

   # http://sequel.rubyforge.org/rdoc/files/doc/validations_rdoc.html
   def validate
      super
   end

   def password= x
      x = User.hash_pw x
      super
   end

   def User.auth user, pw
      hash = User.hash_pw pw
      return User.find(:password => hash, :username => user)
   end

   def User.get userid
      return User.find(:userid => userid)
   end

   # This is written to mimic mysql's password function.
   def User.hash_pw pw
      return "*#{Digest::SHA1.hexdigest(Digest::SHA1.digest(pw)).upcase}"
   end
end
