require 'erb'
require 'byebug'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    begin
      @app.call(env)
    rescue StandardError => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    file_path = "./lib/templates/rescue.html.erb"
    content = ERB.new(File.read(file_path)).result(binding)

    exception_res = Rack::Response.new
    exception_res['Content-Type'] = "text/html"
    exception_res.status = 500
    exception_res.write(content)
    exception_res.finish
    # [exception_res.status.to_s, {'Content-type' => exception_res['Content-Type']}, e.message]
  end

end
