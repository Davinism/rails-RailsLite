require 'byebug'

class Static
  MIME_TYPES = {
    '.txt' => 'text/plain',
    '.jpg' => 'image/jpeg',
    '.zip' => 'application/zip',
    '.png' => 'image/png'
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    file_path = ".#{req.path}"

    if file_path[0..7] == "./public" && File.exist?(file_path)
      res = Rack::Response.new
      res['Content-Type'] = MIME_TYPES[File.extname(file_path)]
      res.write(File.read(file_path))
      res.finish
    elsif file_path[0..7] == "./public" && !File.exist?(file_path)
      res = Rack::Response.new
      res['Content-Type'] = MIME_TYPES[File.extname(file_path)]
      res.status = 404
      res.finish
    else
        @app.call(env)
    end

  end
end
