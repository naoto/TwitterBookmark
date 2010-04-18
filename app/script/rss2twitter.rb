require 'kconv'
require 'rss'
require 'rubygems'
require 'simple_http'
require 'open-uri'
require 'active_record'
require 'timeout'

#DB_Connection
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/development.sqlite3",
  :timeout => 5000
)

class Bookmark < ActiveRecord::Base
end

class User < ActiveRecord::Base
end

# Display parseData
# name: commenter name
# comment: original text
# url: pickup url string
# title: address title
def setData(name, comment, url, title, originaluri)
    # Dose url exist in the bookmarks table
    # exist by update
    # not exist by insert
    record = Bookmark.find_by_uri(url)
    if record
       smbusr = {"name" => name, 
                 "comment" => comment, 
		 "bookmarkid" => record.id}

       userRecord = User.find_by_name_and_bookmarkid(name,record.id)
       unless userRecord
         record.count += 1
         record.save
        
	 @user = User.new(smbusr)
	 @user.save

      end
    else
      sbm = {"uri" => url,
             "title" => title,
	     "count" => 1,
	     "originaluri" => originaluri}
      @bookmark = Bookmark.new(sbm)
      @bookmark.save

      insRecord = Bookmark.find_by_uri(url)

      smbusr = {"name" => name, 
                "comment" => comment, 
        	"bookmarkid" => insRecord.id}

      @user = User.new(smbusr)
      @user.save

    end
end

since_id = "100"
rss_uri = ARGV[0]
while true

#RSS Parse...
warn "since_id================" + since_id
rss_source = SimpleHttp.get(rss_uri,"since_id" => since_id.to_s)
rss = RSS::Parser.parse(rss_source.to_s.toutf8, true)

#URL Regex
rss.channel.items.each do |i|
  
  comment = i.description
  if comment =~ /(^.*?)\:.*?(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)/
    p $2
    name = $1
    url = $2
    comment.to_s.sub!(/^.*?:(.*?)$/,'\\1')
    title = ""
    originaluri = url

    #tinyurk to original url
    begin
       unless chkuri = Bookmark.find_by_originaluri(url)
         open(url){ |f|
	    f.each_line{ |line|
              if line =~ /<title>(.*?)<\/title>/
                title = $1
		title = title.to_s.toutf8
	        break;
	      end
	    }
	    url = f.base_uri.to_s
         }
       else
         warn "exist"
         title = chkuri.title
	 url = chkuri.uri
       end

      setData(name, comment, url, title, originaluri)
    rescue => HTTPError
      warn "HTTPError"
      puts HTTPError.message
    rescue TimeoutError
      warn "Timeout"
    rescue => RuntimeError
      warn "BadGateway"
    rescue => error
      warn "TimeOut?"
    end
  end
  resid = i.link.sub(/^.*?([0-9]+)$/,'\\1')
  warn resid
  since_id = resid if resid > since_id
end
end

