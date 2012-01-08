require 'cinch'
require 'rest_client'
require 'json'

# there are 4 environment variables that must be set for the trellobot to behave
# the way he is supposed to - 
#
# TRELLO_API_KEY : your Trello API developer key
# TRELLO_BOT_CHANNEL : the name of the channel you want trellobot to live on, the server is freenode
# TRELLO_BOARD_API_URL : the trellobot looks at only one board and the lists on it, put the api url here
# TRELLO_BOARD_HUMAN_URL : the trellobot will send the human here if he can't get the lists or cards

$board = nil

def sync_board
  data = RestClient.get ENV['TRELLO_BOARD_API_URL'], {:params => {:key => ENV['TRELLO_API_KEY']}, :accept => "json"}
  $board = JSON.parse(data)
end

def say_help(msg)
  msg.reply "I can tell you the open cards on the lists on your Trello board. Just address me with the name of the list (it's not case sensitive)."
  msg.reply "For example - trellobot: ideas"
  msg.reply "I also understand the these commands : "
  msg.reply "  -> 1. help - shows this!"
  msg.reply "  -> 2. sync - resyncs my cache with the board."
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.net"
    c.nick = "trellobot"
    c.channels = [ENV['TRELLO_BOT_CHANNEL']]
    sync_board
  end

  # trellobot is polite, and will only reply when addressed
  on :message, /^trellobot[_]*:/ do |m|
    # if trellobot can't get thru to the board, then send the human to the human url
    sync_board unless $board
    unless $board
      m.reply "I can't seem to get the list of ideas from Trello, sorry. Try here: #{ENV['TRELLO_BOARD_HUMAN_URL']}" 
      bot.halt
    end
    
    # trellobot: what up?  <- The bit we are interested in is past the ':'
    parts = m.message.split(':',2)
    searchfor = parts[1].strip.downcase
    
    case searchfor
      when /help/
        say_help(m)
      when /sync/
        sync_board
        m.reply "Ok, synced the board, #{m.user.nick}."
      else
        if searchfor.length > 0
          # trellobot presumes you know what you are doing and will attempt
          # to retrieve cards using the text you put in the message to him
          # at least the comparison is not case sensitive
          list = $board.select { |l| searchfor.eql?(l['name'].strip.downcase)}
          if list.empty?
            m.reply "There's no list called <#{searchfor}> on the board, #{m.user.nick}. Sorry."
          else
            cards = list[0]['cards']
            if cards.count == 0
              m.reply "Nothing doing on that list today, #{m.user.nick}."
            else
              ess = (cards.count == 1) ? "" : "s"
              m.reply "I have #{cards.count} card#{ess} today"
              inx = 1
              cards.each { |i|
                m.reply "  ->  #{inx.to_s}. #{i['name']}"
                inx += 1
              }
            end
          end
        else
          say_help(m)
        end
    end 
  end
  
  # if trellobot loses his marbles, it's easy to disconnect him from the server
  # note that if you are doing a PaaS deploy, he may respawn depending on what 
  # the particular hosting env is (e.g. Heroku will start him up again)
  on :private, /quit/ do |m|
    bot.quit
  end
end

bot.start
