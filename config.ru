require "rubygems"
require "bundler"
require "digest/md5"
Bundler.require(:default)

require File.dirname(__FILE__) + "/app.rb"
run Sinatra::Application
