class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    bookmarkid = params["bookmark"]
    @users = User.find(:all,:conditions=>["bookmarkid = ?",bookmarkid],:order=>"id DESC")
    @bookmark = Bookmark.find(bookmarkid)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def show
    id = params['id']
    #@user = User.find(:first,:joins => "Left JOIN bookmarks on bookmarks.id = users.bookmarkid", :conditions=>["name = ?",id])
    @user = User.find(:first,:include => ['bookmark'], :conditions=>["name = ?",id])

    respond_to do |format|
      format.html
      format.xml
    end
  end
end
