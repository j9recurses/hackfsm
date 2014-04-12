require 'bundler'
Bundler.require
require 'sinatra/form_helpers'

# load the Database and User model
require './model'
require 'rack/flash'


class Hackfsm < Sinatra::Base
  use Rack::Session::Cookie, secret: "nothingissecretontheinternet"
  use Rack::Flash, accessorize: [:error, :success]
  use Rack::Logger
  error_logger = Logger.new('errors.log')

  use Warden::Manager do |config|
    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information.
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      # "strategies" is an array of named methods with which to
      # attempt authentication. We have to define this later.
      strategies: [:password],
      # The action is a route to send the user to when
      # warden.authenticate! returns a false answer. We'll show
      # this route below.
      action: 'auth/unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['username'] && params['user']['password']
    end

    def authenticate!
      user = User.first(username: params['user']['username'])
      if user.nil?
        fail!("The username you entered does not exist.")
       # flash[:error] = "Format of the email was wrong."
      elsif user.authenticate(params['user']['password'])
        #flash.success = "Successfully Logged In"
        success!(user)
        @sessions = request.env['rack.session']['secret']
        Kernel.puts @session

        puts @sessions
        puts "*****"
        message = "The random number is #{rand(100)}"
        env['rack.session']['message'] = message

      else
        fail!("Could not log in")
      end
    end
  end

 
  get '/' do
    erb :index
  end

  # create
  post '/' do
    @query = params[:tag_body]
    if @query
      @api_string = 'https://apis.berkeley.edu/solr/fsm/select?q=' +@query+ '&wt=json&indent=on&app_id=ae8269cd&app_key=06dcf6f2f95a61627cb6105268c6420f'
      @stuff = RestClient.get @api_string
      s = SearchTerm.new
      s.search_query_term = @query
      s.search_api_string = @api_string
      s.save
      erb :show
    end
  end

  get '/auth/login' do
    erb :login
  end

  post '/auth/login' do
    env['warden'].authenticate!

    flash.success = env['warden'].message

    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash.success = 'Successfully logged out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    puts env['warden.options'][:attempted_path]
    flash.error = env['warden'].message || "You must log in"
    redirect '/auth/login'
  end

  get '/protected' do
    env['warden'].authenticate!

    erb :protected
  end

  get '/user/signup' do
    erb :newuser
  end

  post '/user/signup' do
    @user = User.new(params[:user])
    if @user.save
      redirect "user/#{@user.id}"
    else
      output = @user.errors
      erb :error_template
    end
  end

  get "/user/:id" do
    @currentuser = User.first(params[:id])
    erb :show
  end

 



end


