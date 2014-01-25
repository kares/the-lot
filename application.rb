require './database'
require './db/models/user'
require './db/models/task'

# Authentication

def current_user # user or raise
  User.new(:name => 'default', :created_at => Time.current) # DRAFT
end

def current_user?
  return true # DRAFT
  session[:current_user]
end

get '/' do
  if current_user?
    redirect to('/tasks')
  else
    redirect to('/login')
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

def task_params
  task = {}
  ['name', 'completed', ''].each do |name|
    task[name.to_sym] = params[name] if params.key?(name)
  end
  task
end

get '/tasks' do
  current_user.all_tasks.to_json
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