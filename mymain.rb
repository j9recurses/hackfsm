require 'bundler'
Bundler.require
require 'sinatra/form_helpers'

# load the Database and User model
require './model'
require 'rack/flash'
require 'json'

set :public_folder, File.dirname(__FILE__) + '/static'

  #index page
  get '/' do
    erb :search
  end



  # search landing page 
  post '/' do
    @query = params[:search]
    if @query
      @api_string = 'https://apis.berkeley.edu/solr/fsm/select?q=' +@query+ '&wt=json&indent=on&app_id=ae8269cd&app_key=06dcf6f2f95a61627cb6105268c6420f'
      @stuff = RestClient.get @api_string
      @newstuff = JSON.parse(@stuff)
      @cool2 = @newstuff.length
      @docs =  @newstuff["response"]
      if @docs["numFound"] == 0 
        @numberitems =  0
        @myresults = "No Results Found"
      else
        @numberitems =  @docs["numFound"]
        @myresults = @docs["docs"]
      end
      erb :searchresults
    end
  end

require 'cgi'
get '/singleresult' do
    @free_req = params
    @awesome = params
    @title = params["title"] 
    @imgurl =  params["imgurl"]
    @creator =  params["creator"]
    @typeresource1 =  params['typeresource']
    @relatedtitle = params['relatedtitle']
    @location = params['location']
    @imgurl = @imgurl.split('$')
    @relatedtitle= @awesome['relatedtitle']
    @id = params["id"]
    idz =  @id
    @mytags = Tag.all(:metaid => params["id"])
    @coolz =  Tag.aggregate(:all.count, :metaid.count)
  erb:singleresult
end


post '/cool' do
   tagstr = params[:fsmTag]
   @stuff = params[:fsmTag]
   mymetaid = params[:metaid]
   tag = Tag.create(:mytag =>  tagstr)
   tag.metaid = mymetaid
   tag.save
   tag.metaid = mymetaid  
  erb :cool, :layout => false
end
# Create a test User
#if User.count == 0
#  @user = User.create(username: "admin")
 # @user.password = "admin"
#  @user.save
#end

  

  get "/user/:id" do
    @currentuser = User.first(params[:id])
    erb :show
  end

 






