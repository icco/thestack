# This deals with the posts. We can't really use active model because of the
# way SDB works and how we use a different DB depending on the user.
#
# NOTE:
# First you specify a bucket, a unique name for an item in the bucket, and the
# attributes for that item. so you can imagine that the item name is the
# primary key and all of the objects other data are the attributes.
class Post
   @@domain = 'thestack_posts'
   attr_accessor :text, :title, :date, :tags, :userid
   attr_accessor :postid
   attr_reader   :db

   def initialize userid
      @userid = userid
      u = User.get @userid
      @db = u.aws_db
      @tags = []

      # Make sure our domain exists
      if @db.list_domains[:domains].index(@@domain).nil?
         @db.create_domain @@domain
      end

      @postid = Guid.new
   end

   # Needs to create revisions on save.
   def save
      # http://rightscale.rubyforge.org/right_aws_gem_doc/classes/RightAws/SdbInterface.html#M000238
      self.date = Time.now.to_i

      attr = {
         'text' => self.text,
         'title' => self.title,
         'date' => self.date,
         'tags' => self.tags,
      }

      @db.put_attributes(@@domain, self.postid, attr, :replace)

      PostRevision.build self
   end

   # Makes the classic "x thing ago"
   #
   # TODO: deal with yesterday, words for values less than ten
   def nice_date
      Utils.nice_date self.date
   end

   def tags= newtags
      if newtags.is_a? String
         @tags = newtags.split(' ')
      elsif newtags.is_a? Array
         @tags = newtags
      else
         @tags = []
      end
   end

   def tags
      @tags.sort
   end

   def add_tag x
      self.tags = [] if self.tags.nil?
      self.tags[] = x
   end

   def title
      if @title.empty? then "Post ##{self.postid}" else @title end
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

   def revisions
      PostRevision.getRevisions self
   end

   def Post.build id, userid
      p = Post.new userid
      p.postid = id
      data = p.db.get_attributes(@@domain, id)[:attributes]
      p.date   = data['date'].pop.to_i
      p.text   = data['text'].pop
      p.title  = data['title'].pop
      p.tags   = data['tags']

      return p
   end

   def Post.getPosts userid
      db = User.get(userid).aws_db
      query = ["select * from #{@@domain} where date < ? order by date desc", Time.now.to_i ] 
      values = db.select(query)[:items]

      posts = []
      values.each {|result|
         result.each_pair {|key, data|
            p = Post.new userid
            p.date   = data['date'].pop.to_i
            p.text   = data['text'].pop
            p.title  = data['title'].pop
            p.tags   = data['tags']
            p.postid = key
            posts.push(p)
         }
      }

      return posts
   end

   # a very simple search
   # TODO: implement
   def Post.search string
      #Post.filter(:title.like("%#{string}%") | :text.like("%#{string}%") | :tags.like("%#{string}%"))
      []
   end

   # TODO: implement
   def Post.tagsearch tag
      #Post.filter(:tags.like("%#{tag}%"))
      []
   end
end
