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

# Authentication

helpers do

  def current_user # user or raise
    if session[:user_id]
      set_current_user User.find(session[:user_id])
    else
      current_user? ? @current_user : halt(401)
    end
  end

  def current_user?
    return true if session[:user_id]
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    if @auth.provided? && @auth.basic? && @auth.credentials
      set_current_user User.auth( *@auth.credentials ) # [ name, password ]
    end
  end

  def set_current_user(user)
    if user
      session[:user_id] = user.id
      @current_user = user
    else
      session.delete(:user_id); @current_user = nil
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
    @post_params ||= begin
      body = request.body.read
      body.present? ? JSON.parse(body) : {}
    end
  end

  def debug(msg)
    puts msg # settings.logger.debug msg
  end

end

# TODO errors - 404 on not found & 422 on validations errors

post '/signup' do
  debug "POST user params: #{post_params.inspect}"
  unless user_params = post_params['user']
    user_params = {}
    name = post_params['username'] || params['username']
    user_params[:name] = name if name
    pass = post_params['password'] || params['password']
    user_params[:password] = pass if pass
  end
  if user_params.empty?
    status 422
  else
    set_current_user User.create!(user_params)
    status 201
  end
end

get '/login' do
  current_user.to_json only: [ :id, :name, :created_at ]
end

post '/login' do
  if user = User.auth( post_params['username'], post_params['password'] )
    set_current_user user
    status 200
  else
    status 401
  end
end

post '/logout' do
  set_current_user nil
  status 200
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
  debug "POST task params: #{post_params.inspect}"

  if ( task_params = post_params['task'] ).blank?
    if name = params['name']
      task_params = { name: params['name'] }
    else
      status 400; return
    end
  end
  current_user.tasks.create! task_params
  status 201
end

put '/tasks/:id' do
  debug "PUT task params: #{post_params.inspect}"

  task = current_user.find_task(params['id'])
  
  if ( task_params = post_params['task'] || {} ).empty?
    task_params[:name] = params['name'] if params['name']
    task_params[:completed] = params['completed'].to_s == 'true' if params['completed']
    if task_params.empty?
      status 202; return
    end
  end
  task.update_attributes! task_params
  status 204
end

delete '/tasks/:id' do
  current_user.find_task(params['id']).destroy!
  status 202
end

puts "The-Lot Sinatra smokin' ..."