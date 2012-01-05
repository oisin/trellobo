require 'cinch'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = "trellobot"
    c.channels = ["#dublinjs"]
  end

  on :message, /trellobot/ do |m|
    m.reply "Hello, #{m.user.nick}. It is my first day, and I am clueless."
  end
end

bot.start
