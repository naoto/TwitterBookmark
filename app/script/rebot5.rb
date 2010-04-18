require 'kconv'
require 'rubygems'
require 'open-uri'
require 'active_record'
require 'timeout'

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/development.sqlite3",
    :timeout => 5000
)

class Bookmark < ActiveRecord::Base
end

class User < ActiveRecord::Base
end

class TempBase < ActiveRecord::Base
    self.abstract_class = true
end

TempBase.establish_connection(
      :adapter => "sqlite3",
      :database => "db/tempdb.sqlite3",
      :timeout => 5000
)

class Temptbl < TempBase
end

def update(bookmarkRecord, name, comment)
  userRecord = User.find_by_name_and_bookmarkid(name,bookmarkRecord.id)
  unless userRecord
    bookmarkRecord.count += 1
    #@bookmark = Bookmark.new(bookmarkRecord)
    bookmarkRecord.save

    userdata = {"name" => name,
                "comment" => comment,
                "bookmarkid" => bookmarkRecord.id}

    @user = User.new(userdata)
    @user.save
    return true;
  else
    return false;
  end
end

def insert(uri, title, originaluri, name, comment)
  bookmarkdata = {"uri" => uri,
                   "title" => title,
                   "count" => 1,
                   "originaluri" => originaluri}
  
  @bookmark = Bookmark.new(bookmarkdata)
  @bookmark.save

  insRecord = Bookmark.find_by_uri(uri)
  
  userdata = {"name" => name,
              "comment" => comment,
              "bookmarkid" => insRecord.id
             }
  @user = User.new(userdata)
  @user.save
end

while true
  tempRecord = Temptbl.find(:first, :order => 'comment DESC')
  warn tempRecord.id
  next unless tempRecord
  uri = tempRecord.comment.to_s.sub(/^.*?\:.*?(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+).*?$/,'\\1')
  warn uri
  originaluri = uri
  bookmarkRecord = Bookmark.find_by_originaluri(uri)
  bookmarkRecord = Bookmark.find_by_uri(uri) unless bookmarkRecord
  name = tempRecord.comment.to_s.sub(/^(.*?):.*?$/,'\\1')
  comment = tempRecord.comment.to_s.sub(/^.*?:(.*?)$/,'\\1')

  if bookmarkRecord
    update(bookmarkRecord, name, comment)
  else
    
    begin
      title = ""
      open(uri){ |f|
        f.each_line{ |line|
          if line =~ /<title>(.*?)<\/title>/
            title = $1
            title = title.to_s.toutf8
            break;
          end
        }
        uri = f.base_uri.to_s
      }
     
      bookmarkRecord = Bookmark.find_by_uri(uri)
      if bookmarkRecord
        update(bookmarkRecord, name, comment)
      else
        insert(uri,title,originaluri,name,comment)
      end
    rescue => HTTPError
      warn "HTTPError => " + HTTPError.message
      warn uri
    rescue TimeoutError
      warn "Timeout"
      warn uri
    rescue =>RuntimeError
      warn "RuntimeError"
      warn uri
    end
  end
  Temptbl.delete(tempRecord.id)
end
