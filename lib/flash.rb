require 'json'

class Flash
  COOKIE_NAME = "_rails_lite_app_flash"

  def initialize(req)
    @req = req
    if @req.cookies.keys.include?(COOKIE_NAME)
      @now = JSON.parse(@req.cookies[COOKIE_NAME])
    else
      @now = {}
    end
    @cookie = {}
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_flash(res)
    res.set_cookie(COOKIE_NAME, path: "/", value: @cookie.to_json)
  end

  def [](key)
    @cookie.merge(@now)[key]
  end

  def now
    @now
  end
end
