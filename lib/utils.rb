# Static functions that we use often...
class Utils
   # Makes the classic "x thing ago"
   #
   # TODO: deal with yesterday, words for values less than ten
   def Utils.nice_date date
      distance = date ? Time.now.to_i - date : 0

      out = case distance
            when 0 .. 59 then "#{distance} seconds ago"
            when 60 .. (60*60) then "#{distance/60} minutes ago"
            when (60*60) .. (60*60*24) then "#{distance/(60*60)} hours ago"
            when (60*60*24) .. (60*60*24*30) then "#{distance/((60*60)*24)} days ago"
            else Time.at(date).strftime("%m/%d/%Y")
         end

      out.sub(/^1 (\w+)s ago$/, '1 \1 ago')
   end

   def Utils.guid
      Guid.new
   end
end
