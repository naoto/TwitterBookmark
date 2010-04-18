class BookmarksController < ApplicationController
  # GET /bookmarks
  # GET /bookmarks.xml
  def index
    level = 3
    level = params['level'] if params['level']
    uplevel = level.to_i + 1
    uplevel = 1000 if level == "5" 

    type = params['type']
    if params['type'] == nil then
      #@bookmarks = Bookmark.find(:all, :conditions=>["count>=? and count<=?",level,uplevel], :order=>'strftime(\'%Y%m%d%H%M\',updated_at) DESC,count DESC')
      @bookmarks = Bookmark.paginate(:per_page => 50, :page => params[:page], :conditions=>["count>=? and count<=?",level,uplevel], :order=>'strftime(\'%Y%m%d%H%M\',updated_at) DESC,count DESC')
    elsif type == "nico"
      @bookmarks = Bookmark.paginate(:per_page => 50, :page => params[:page], :conditions=>["uri like ?","http://www.nicovideo.jp/%"], :order=>'strftime(\'%Y%m%d%H%M\',updated_at) DESC,count DESC')
    elsif type == "url"
      @bookmarks = Bookmark.paginate(:per_page => 50, :page => params[:page], :conditions=>["uri like ?","http://" + params['url'] + "%"], :order=>'strftime(\'%Y%m%d%H%M\',updated_at) DESC,count DESC')
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookmarks }
    end
  end
end
