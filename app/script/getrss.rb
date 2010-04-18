require 'kconv'
#require 'rss'
require 'rubygems'
#require 'simple_http'
require 'active_record'
require 'feed-normalizer'
require 'pp'

#DB_Connection
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/tempdb.sqlite3",
  :timeout => 5000
)

class Temptbl < ActiveRecord::Base
end

since_id = 100
rss_uri = ARGV[0]
while true
  begin
    #rss_source = SimpleHttp.get(rss_uri,"since_id" => since_id.to_s)
    #rss_source = SimpleHttp.get(rss_uri,"rss" => "")
    #puts "r"
    #rss = RSS::Parser.parse(rss_source.to_s.toutf8,true)
    p rss_uri
    rss = FeedNormalizer::FeedNormalizer.parse(open(rss_uri),:force_parser => FeedNormalizer::SimpleRssParser)
p rss.entry.size
    rss.entry.each do |item|

      comment = item.summary
      statusid = item.link.attributes['href']#item.urls[0].to_s.sub(/^.*?([0-9]+)$/,'\\1')
      #warn statusid 
p comment
p statusid
exit
      if comment =~ /(^.*?)\:.*?(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)/
        warn $2
        unless Temptbl.find_by_statusid(statusid)
          urlcomment = {"statusid" => statusid,
                        "comment" => comment,
                        "created_at" => Time.now}

          @temptbl = Temptbl.new(urlcomment)
          @temptbl.save
        end
      end
      since_id = statusid if since_id.to_i < statusid.to_i
    end
  rescue 
    warn "NET::ERROR"
  end
  warn "since_id========================" + since_id.to_s
  sleep 60 
end
