require 'bundler/setup'
Bundler.require

require 'sinatra'
require 'sinatra/activerecord'

set :database, ENV['DATABASE_URL'] || begin
  pool = ENV['DB_POOL'] || 20 # free PG only 20 connections
  adapter = ENV['DATABASE_ADAPTER'] || 'postgresql'
  # PGUSER, PGPASSWORD, PGHOST will be picked up automatically
  "#{adapter}:///#{ENV['PGDATABASE'] || 'the-lot'}?pool=#{pool}"
end

ActiveRecord::Base.include_root_in_json = true