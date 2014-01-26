require './database'
require './db/models/user'
require './db/models/task'

# Configuration

enable :sessions, :logging, :static, :method_override
set :public_folder, 'public'
set :session_secret, 'saso-vesia-osusku' * 3

configure :development do
  require 'sinatra/reloader'
  register Sinatra::Reloader
end

def logger; settings.logger; end

# Authentication

helpers do

  def current_user # user or raise
    name = 'default' # DRAFT
    return User.where(name: name).take || begin
      user = User.create!(name: name)
      user.tasks.create! name: 'wash dishes'
      user
    end


    if session[:current_user]
      set_current_user User.find(session[:current_user])
    else
      current_user? ? @current_user : halt(401)
    end
  end

  def current_user?
    return true if session[:current_user]
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    if @auth.provided? && @auth.basic? && @auth.credentials
      set_current_user User.auth( *@auth.credentials ) # [ name, password ]
    end
  end

  def set_current_user(user)
    if user
      session[:current_user] = user.id
      @current_user = user
    else
      session.delete(:current_user); @current_user = nil
    end
  end

end

get '/' do
  send_file File.join(settings.public_folder, 'index.html') # redirect '/index.html'
end

helpers do

  #require 'active_model/serializer'
  #
  #def serializer(resource, resource_name = nil)
  #  serializer = ActiveModel::Serializer.serializer_for(resource)
  #  options = {}
  #  options[:resource_name] = resource_name if resource_name
  #  serializer.new(resource, options)
  #end

  def post_params
    @post_params ||= JSON.parse(request.body.read)
  end

end

# TODO validations - return 422 on errors and handle on client

post '/signup' do
  unless user_params = post_params['user']
    user_params = { name: params['name'], password: params['password'] }
  end
  if user_params.empty?
    status 422
  else
    set_current_user User.create!(user_params)
    status 201
  end
end

get '/login' do
  current_user.to_json
end

post '/login' do
  # TODO NOT IMPLEMENTED
  status 200
end

post '/logout' do
  # TODO NOT IMPLEMENTED
end

# Task API

get '/tasks' do
  tasks = current_user.all_tasks
  { tasks: tasks }.to_json methods: :completed
end

get '/tasks/:id' do
  current_user.find_task(params['id']).to_json methods: :completed
end

post '/tasks' do
  logger.debug "POST task params: #{post_params.inspect}"

  if (task_params = post_params['task']).empty?
    status 400
  else
    current_user.tasks.create! task_params
    status 201
  end
end

put '/tasks/:id' do
  logger.debug "PUT task params: #{post_params.inspect}"

  task = current_user.find_task(params['id'])
  if (task_params = post_params['task']).empty?
    status 202
  else
    task.update_attributes! task_params
    status 204
  end
end

delete '/tasks/:id' do
  current_user.find_task(params['id']).destroy!
  status 202
end

puts "The-Lot Sinatra smokin' ..."