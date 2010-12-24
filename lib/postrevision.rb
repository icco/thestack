# TODO: make a library to deal with ugly code duplication.
class PostRevision
   @@domain = 'thestack_postrevisions'
   attr_accessor :text, :title, :date, :tags, :postid, :revisionid
   attr_reader   :db

   def initialize userid
      @userid = userid
      u = User.get @userid
      @db = u.aws_db

      # Make sure our domain exists
      if @db.list_domains[:domains].index(@@domain).nil?
         @db.create_domain @@domain
      end

      self.revisionid = Guid.new
   end

   def diff_text
      previous = self.previous

      text = previous ? previous.text : ""

      diff = Differ.diff_by_word(self.text, text)

      return diff
   end

   def diff_title
      previous = self.previous

      text = previous ? previous.title : ""

      diff = Differ.diff_by_word(self.title, text)

      return diff
   end

   def diff_tags
      previous = self.previous

      text = previous ? previous.tags.join(' ') : ""

      diff = Differ.diff_by_word(self.tags.join(' '), text)

      return diff
   end

   def nice_date
      Utils.nice_date self.date
   end

   def previous
      query = ["['postid' = ?] intersection ['date' < ?] sort 'date' desc", self.postid, self.date]
      values = @db.query_with_attributes(@@domain, [], query, 1)[:items]

      posts = []
      values.each {|value|
         value.each_pair {|key, data|
            p = PostRevision.new(@userid)
            p.date   = data['date'].pop.to_i
            p.text   = data['text'].pop
            p.title  = data['title'].pop
            p.tags   = data['tags']
            p.postid = data['postid']
            p.revisionid = key
            posts.push(p)
         }
      } if !values.nil?

      return !values.nil? ? posts.pop : nil
   end

   def save
      attr = {
         'text' => self.text,
         'title' => self.title,
         'date' => self.date,
         'tags' => self.tags,
         'postid' => self.postid
      }

      @db.put_attributes(@@domain, self.revisionid, attr)
   end

   def PostRevision.getRevisions post
      pr = PostRevision.new post.userid
      db = pr.db
      query = ["['postid' = ?] intersection ['date' <= ?] sort 'date' desc", post.postid, Time.now.to_i]
      values = db.query_with_attributes(@@domain, [], query)[:items]

      posts = []
      values.each {|row|
         row.each_pair {|key, data|
            p = PostRevision.new post.userid
            p.date   = data['date'].pop.to_i
            p.text   = data['text'].pop
            p.title  = data['title'].pop
            p.tags   = data['tags']
            p.postid = data['postid']
            p.revisionid = key
            posts.push(p)
         }
      } if !values.nil?

      return posts
   end

   def PostRevision.build post
      pr = PostRevision.new post.userid

      attributes = [
         'date',
         'title',
         'text',
         'tags',
         'postid',
      ]

      # loops through everything we want to save and copies it.
      attributes.each{|col|
         eval("pr.#{col} = post.#{col}")
      }

      pr.save
   end
end

