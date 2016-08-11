require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './flash'
require 'securerandom.rb'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  def self.protect_from_forgery
    @check_for_authenticity = true
  end

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise "Already built this response!"
    else
      @res['Location'] = url
      @res.status = 302
      @already_built_response = true
      @session.store_session(@res) if @session
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise "Already built this response!"
    else
      @already_built_response = true
      @res['Content-Type'] = content_type
      @res.write(content)
      @session.store_session(@res) if @session
      @res.finish
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    file_path = "./views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    content = ERB.new(File.read(file_path)).result(binding)

    render_content(content ,"text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    check_authenticity_token unless @req.request_method == "GET"
    self.send(name)
    unless @already_built_response
      render(name)
    end
  end

  def form_authenticity_token
    flash['authenticity_token'] ||= SecureRandom::urlsafe_base64(16)
    @res.set_cookie('authenticity_token', path: "/", value: flash['authenticity_token'])
    flash['authenticity_token']
  end

  def check_authenticity_token
    if self.class.instance_variable_get(:@check_for_authenticity)
      unless @req.cookies['authenticity_token'] == @params['authenticity_token'] && !@req.cookies['authenticity_token'].nil?
        raise "Invalid authenticity token"
      end
    end
  end

end
