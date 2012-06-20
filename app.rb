# -*- coding: UTF-8 -*-
require "sinatra"
require "sinatra/activerecord"
require "sinatra/content_for"
require "rack/csrf"
require "redcarpet"
require "coderay"

configure do
  set :database, ENV["DATABASE_URL"] || "sqlite:///production.sqlite3"
  set :public_folder, File.dirname(__FILE__) + '/static'
  set :haml, {:escape_html => true}

  use Rack::Session::Cookie
  use Rack::Csrf, :raise => true

  ActiveRecord::Base.logger = Logger.new("log/database.log")
end

configure :production do
  set :scss, {:style => :compressed}
end

class Post < ActiveRecord::Base
  validates :content, :presence => true
end

class HTMLwithCoderay < Redcarpet::Render::HTML
  def block_code(code, language)
    CodeRay.scan(code, language).div(:css => :class)
  end
end

get "/application.css" do
  content_type "text/css", :charset => "utf-8"
  scss :application
end

get "/" do
  @post = Post.new
  haml :new
end

post "/" do
  @post = Post.new
  @post.content = params[:content]
  @post.hash_id = Digest::MD5.hexdigest(env["rack.session"][:session_id] + Time.now.to_i.to_s)

  if @post.save
    redirect "/#{@post.hash_id}"
  else
    redirect "/"
  end
end

post "/preview" do
  markdown(params[:content])
end

get "/:hash_id.:format" do
  begin
    @post = Post.find_by_hash_id(params[:hash_id])

    case params[:format]
    when "md", "mkd", "markdown" then
      template = :markdown
      content = markdown(@post.content)
    when "txt", "text" then
      content_type :text
      return @post.content
    else
      redirect "/"
    end
    haml template, :locals => {:content => content, :style => false}
  rescue
    redirect "/"
  end
end

get "/:hash_id" do
  begin
    @post = Post.find_by_hash_id(params[:hash_id])
    haml :show, :locals => {:content => markdown(@post.content)}
  rescue
    redirect "/"
  end
end

get "/:hash_id/edit" do
  @post = Post.find_by_hash_id(params[:hash_id])
  haml :edit
end

put "/:hash_id" do
  @post = Post.find_by_hash_id(params[:hash_id])
  @post.content = params[:content]

  if @post.save
    redirect "/#{@post.hash_id}"
  else
    haml :edit
  end
end

delete "/:hash_id" do
  @post = Post.find_by_hash_id(params[:hash_id])
  @post.destroy

  redirect "/"
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def markdown(text)
    rndr = HTMLwithCoderay.new(:filter_html => true, :hard_wrap => true)
    markdown = Redcarpet::Markdown.new(rndr, :autolink => true, :space_after_headers => true, :fenced_code_blocks => true, :tables => true)
    markdown.render(text)
  end
end
# vim: set fenc=utf-8
