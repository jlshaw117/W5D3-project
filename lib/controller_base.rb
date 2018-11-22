require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'byebug'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
  end


  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response = !@already_built_response
    return !@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    @res.status = 302
    @res["Location"] = url
    raise 'Double Render Error' if already_built_response?
    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    @res['Content-Type'] = content_type
    @res.write(content)
    raise 'Double Render Error' if already_built_response?
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = File.dirname(__FILE__)

    folder_name = self.class.to_s.downcase[0...-10] + "_controller"

    new_path = File.join(path, "../views", "#{folder_name}", "#{template_name}.html.erb")
    file_contents = File.read(new_path)
    render_content(ERB.new(file_contents).result(binding), "text/html")
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
  end
end
