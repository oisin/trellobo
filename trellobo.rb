require 'cinch'
require 'rest_client'
require 'json'

$board = nil

def sync_board(url)
  data = RestClient.get url, {:params => {:key => "9b0e45ad3343361401c0465c5278a74d"}, :accept => "json"}
  $board = JSON.parse(data)
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = "trellobot"
    c.channels = ["#oisintester"]
    sync_board "https://api.trello.com/1/boards/4f05b412cf33c09c016a90df/lists"
  end

  on :message, /^trellobot/ do |m|
    puts "Mesage is " + m.message
    if m.message =~ /ideas/ 
      ideas_list = $board.select { |l| "Ideas".eql?(l['name'])}
      unless ideas_list.empty?
        cards = ideas_list[0]['cards']
        m.reply "I have about #{cards.count} ideas today"
        cards.each { |i|
          m.reply "  ->  #{i['name']}"
        }
      else
        m.reply "Ideas? You're looking for ideas, #{m.user.nick}?."
      end
    else
      m.reply "Ok, I don't know what that meant."
    end
  end
end

bot.start
