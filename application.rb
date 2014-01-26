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

  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def current_user # user or raise
    name = 'default' # DRAFT
    User.where(name: name).take || begin
      user = User.create!(name: name)
      user.tasks.create! name: 'wash dishes'
      user
    end
  end

  def current_user?
    return true if true # DRAFT

    return true if session[:current_user]
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    if @auth.provided? && @auth.basic? && @auth.credentials
      set_current_user User.auth( *@auth.credentials ) # [ name, password ]
    end
  end

  def set_current_user(user)
    if user
      session[:current_user] = user
    else
      session.delete(:current_user); nil
    end
  end

end

get '/' do
  send_file File.join(settings.public_folder, 'index.html') # redirect '/index.html'
end

# TODO validations - return 422 on errors and handle on client

post '/signup' do
  User.create! :name => params['name'], :password => params['password']
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

def task_params
  task = {}
  ['name', 'completed'].each do |name|
    task[name.to_sym] = params[name] if params.key?(name)
  end
  task
end

get '/tasks' do
  tasks = current_user.all_tasks.to_json
  puts tasks.inspect
  tasks
end

get '/tasks/:id' do
  current_user.find_task(params['id']).to_json
end

post '/tasks' do
  current_user.tasks.create! task_params
  status 204
end

put '/tasks/:id' do
  task = current_user.find_task(params['id'])
  if (task_params = self.task_params).empty?
    status 200 # 304 maybe ?
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