require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'syntaxi'


#####database
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/main.sqlite3")

class Tag
	include DataMapper::Resource
 	property :id,         Serial 
  	property :tag,        Text,    :required => true  # Cannot be null
	property :userid,     Integer,  :index => true 
	property :metaid,     Integer,  :index => true
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.auto_upgrade!


###sinatra
# new
get '/search' do
  erb :new
end

# create
post '/search' do
  @tag = Tag.new(:tag => params[:tag_body])
  if @tag.save
  	puts "saved tag"
    redirect "/search#{@tag.id}"
  else
  	puts "did not save tag"
    redirect '/search'
  end
end

# show
get '/show/:id' do
  @tag = Tag.get(params[:id])
  if @tag
    erb :show
  else
    redirect '/search'
  end
end