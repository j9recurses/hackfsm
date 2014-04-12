require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'syntaxi'
require 'data_mapper'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/toopaste.sqlite3")

class Snippet
  include DataMapper::Resource

  property :id,        Serial 
  property :body,       Text,   :required => true  # Cannot be null
  property :created_at, DateTime
  property :updated_at, DateTime

  # validates_present :body
  # validates_length :body, :minimum => 1

  Syntaxi.line_number_method = 'floating'
  Syntaxi.wrap_at_column = 80

  def formatted_body
    replacer = Time.now.strftime('[code-%d]')
    html = Syntaxi.new("[code lang='ruby']#{self.body.gsub('[/code]', replacer)}[/code]").process
    "<div class=\"syntax syntax_ruby\">#{html.gsub(replacer, '[/code]')}</div>"
  end
end

DataMapper.auto_upgrade!

# new
get '/' do
  erb :search
end

# create
post '/' do
  @snippet = Snippet.new(:body => params[:snippet_body])
  if @snippet.save
    redirect "/#{@snippet.id}"
  else
    "did not save"
    redirect '/'
  end
end

# show
get '/:id' do
  @snippet = Snippet.get(params[:id])
  if @snippet
    erb :show
  else
    redirect '/'
  end
end