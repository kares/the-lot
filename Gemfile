#ruby=1.9.3
source 'https://rubygems.org'
#if defined? JRUBY_VERSION
# https://devcenter.heroku.com/articles/ruby-support#ruby-versions
#ruby '1.9.3', engine: 'jruby', engine_version: '1.7.6'
#else
#ruby '1.9.3'
#end

gem 'activerecord', '~> 4.0.0'
gem 'pg', :platform => :mri

gem 'rake', :require => nil

gem 'rack', '~> 1.5.2'
gem 'sinatra', '~> 1.4.4'

gem 'sinatra-activerecord', '~> 1.2.3'

group :server do
  gem 'thin', :require => false, :platform => :mri
end

# heroku config:add JRUBY_OPTS="--1.9 -J-Xmx400m -J-XX:+UseCompressedOops -J-noverify"
# DEFAULTS: -Xmx384m -Xss512k
# -J-Xmn128m -J-Xms448m -J-Xmx448m -J-server