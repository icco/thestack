# TODO: make a library to deal with ugly code duplication.
class PostRevision
   def diff_text
      previous = self.previous

      if previous
         diff = Differ.diff_by_word(self.text, previous.text)
      else
         diff = Differ.diff_by_word(self.text, "")
      end

      return diff
   end

   def diff_title
      previous = self.previous

      if previous
         diff = Differ.diff_by_word(self.title, previous.title)
      else
         diff = Differ.diff_by_word(self.title, "")
      end

      return diff
   end

   def diff_tags
      previous = self.previous

      if previous
         diff = Differ.diff_by_word(self.tags, previous.tags)
      else
         diff = Differ.diff_by_word(self.tags, "")
      end

      return diff
   end

   def nice_date
      Utils.nice_date self.date
   end

   def previous
      PostRevision.filter(
         {:postid => self.postid} & (:revisionid < self.revisionid)
      ).order(:revisionid.desc).first
   end

   def PostRevision.build post
      pr = PostRevision.new

      Post.columns.each{|col|
         eval("pr.#{col} = post.#{col}")
      }

      pr.save
   end
end

