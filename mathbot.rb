require 'cinch'
require 'uri'
require 'patron'
require 'configru'

Configru.load do
  just 'config.yml'

  defaults do
    port 6667
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = Configru.server
    c.port     = Configru.port
    c.nick     = Configru.nick
    c.channels = Configru.channels
  end

  helpers do
    def mathtex_url(code)
      "http://www.forkosh.com/mathtex.cgi?" + URI.escape(code)
    end

    def shorten_url(url)
      sess = Patron::Session.new
      sess.timeout = 10
      sess.base_url = "http://da.gd"
      sess.headers['User-Agent'] = 'mathbot/1.0'

      resp = sess.get("/s?url=#{URI.escape(url)}&text=1&strip=1")

      return "Could not shorten URL. Oops!" if resp.status >= 400

      resp.body
    end
  end

  on :message, /^#{Regexp.escape nick}\S*[:,]\s*(.+)$/ do |m, code|
    m.reply(shorten_url(mathtex_url(code)), true)
  end
end

bot.start

