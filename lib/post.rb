# This deals with the posts. We can't really use active model because of the
# way SDB works and how we use a different DB depending on the user.
class Post
   def to_s
      inspect
   end

   # Needs to create revisions on save.
   def save
      super

      PostRevision.build self
   end

   # http://sequel.rubyforge.org/rdoc/files/doc/validations_rdoc.html
   def validate
      super
   end

   # Makes the classic "x thing ago"
   #
   # TODO: deal with yesterday, words for values less than ten
   def nice_date
      distance = self.date ? Time.now.to_i - self.date : 0

      out = case distance
            when 0 .. 59 then "#{distance} seconds ago"
            when 60 .. (60*60) then "#{distance/60} minutes ago"
            when (60*60) .. (60*60*24) then "#{distance/(60*60)} hours ago"
            when (60*60*24) .. (60*60*24*30) then "#{distance/((60*60)*24)} days ago"
            else Time.at(self.date).strftime("%m/%d/%Y")
         end

      out.sub(/^1 (\w+)s ago$/, '1 \1 ago')
   end

   def tags_a
      self.tags.split(' ')
   end

   def add_tag x
      self.tags = "" if self.tags.nil?
      self.tags = self.tags + " #{x}"
   end

   def title
      if super.empty? then "Post ##{self.postid}" else super end
   end

   def nice_text
      md = RDiscount.new(self.text, :smart)
      return md.to_html
   end

   # strips out html of rendered version and returns 100 characters
   def blurb
      post = self.text.length > 100 ? '...' : ''
      return self.nice_text.gsub(/<\/?[^>]+?>/, '').delete("\n").slice(0..100).rstrip + post
   end

   # Gives a rough idea of how "big" this post is.
   def size
      charPerKb = 128.to_f

      text_size = self.text.length.to_f/charPerKb
      title_size = self.title.length.to_f/charPerKb

      return "#{text_size + title_size} kb"
   end

   def children
      return Post.filter(:parent => self.postid)
   end

   def children?
      return self.children.count > 0
   end

   def revisions
      PostRevision.filter(:postid => self.postid).order(:revisionid.desc)
   end

   def Post.build id
      Post.find(:postid => id)
   end

   def Post.getPosts
      Post.order(:date.desc).limit(10)
   end

   # a very simple search
   def Post.search string
      Post.filter(:title.like("%#{string}%") | :text.like("%#{string}%") | :tags.like("%#{string}%"))
   end

   def Post.tagsearch tag
      Post.filter(:tags.like("%#{tag}%"))
   end
end
