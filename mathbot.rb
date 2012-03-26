require 'cinch'
require 'cgi'
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
    def mathbin(code)
      sess = Patron::Session.new
      sess.timeout = 10
      sess.base_url = "http://mathbin.net"
      sess.headers['User-Agent'] = 'mathbot/1.0'

      escaped_code = CGI.escape("[EQ]#{code}[/EQ]")
      resp = sess.post("/", "name=mathbot&save=1&body=#{escaped_code}")

      return "Could not post to mathbin.net. Oops!" if resp.status >= 400

      resp.url
    end
  end

  on :message, /^#{Regexp.escape nick}\S*[:,]\s*(.+)$/ do |m, code|
    m.reply(mathbin(code), true)
  end
end

bot.start

