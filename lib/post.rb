# This deals with the posts. We can't really use active model because of the
# way SDB works and how we use a different DB depending on the user.
#
# NOTE:
# First you specify a bucket, a unique name for an item in the bucket, and the
# attributes for that item. so you can imagine that the item name is the
# primary key and all of the objects other data are the attributes.
class Post
   @@domain = 'thestack_posts'
   attr_accessor :text, :title, :date, :tags
   attr_reader :postid

   def initialize
      u = User.get session['userid']
      @db = u.db

      if @db.list_domains[:domains].index(@@domain).nil?
         @db.create_domain @@domain
      end

      @postid = Guid.new
   end

   def to_s
      inspect
   end

   # Needs to create revisions on save.
   def save
      # http://rightscale.rubyforge.org/right_aws_gem_doc/classes/RightAws/SdbInterface.html#M000238
      # Put the attributes, save a revision

      PostRevision.build self
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

   def add_tag x
      self.tags = [] if self.tags.nil?
      self.tags[] = x
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
