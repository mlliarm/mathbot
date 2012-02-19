require 'cinch'
require 'cgi'
require 'patron'

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = "irc.tenthbit.net"
    c.nick     = "mathbot"
    c.channels = ["#offtopic", "#programming", "#bots"]
  end

  helpers do
    def mathtex_url(code)
      "http://www.forkosh.com/mathtex.cgi?" + CGI.escape(code)
    end

    def shorten_url(url)
      sess = Patron::Session.new
      sess.timeout = 10
      sess.base_url = "http://da.gd"
      sess.headers['User-Agent'] = 'mathbot/1.0'

      resp = sess.get("/s?url=#{CGI.escape(url)}&text=1&strip=1")

      return "Could not shorten URL. Oops!" if resp.status >= 400

      resp.body
    end
  end

  on :message, /^#{Regexp.escape nick}\S*\s*(.+)$/ do |m, code|
    m.reply(shorten_url(mathtex_url(code)), true)
  end
end

bot.start

