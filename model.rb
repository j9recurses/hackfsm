
require 'bundler'
Bundler.require


#####database###########
DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, 'mysql://myrailsbuddy:mypass@localhost/fsmhack')
DataMapper::Model.raise_on_save_failure = true

class Tag
	include DataMapper::Resource
 	property :id,         Serial, :key => true
  property :tag,        Text,   :required => true  # Cannot be null
	property :metaid,     String
	property :created_at, DateTime
	property :updated_at, DateTime
end

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, :key => true
  property :username, String    #,    :length => 3..50, :unique => true, message: "That user name is taken, try another one."
  property :password, BCryptHash
  property :email, BCryptHash  #,   #:format => :email_address,  message: "Email cannot be blank."
  property :organization, String #, #:length => 3..50
 #has n, :tags, 

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end
end

class SearchTerm
  include DataMapper::Resource
  property :id,         Serial, :key => true
  property :searchterm, Text,    :required => true  # Cannot be null
  property :userid,     Integer,  :index => true 
  property :search_query_term, Text  
  property :search_api_string, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  belongs_to :user
end


DataMapper.finalize
DataMapper.auto_upgrade!

# Create a test User
#if User.count == 0
#  @user = User.create(username: "admin")
 # @user.password = "admin"
#  @user.save
#end
