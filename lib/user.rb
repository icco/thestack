
class User < Sequel::Model(:users)
   def User.auth user, pw
      return true
   end
end
