require 'cinch'
require 'trello'
require 'json'

# You will need an access token to use ruby-trello 0.3.0 or higher, which trellobo depends on. To
# get it, you'll need to go to this URL:
#
# https://trello.com/1/connect?key=DEVELOPER_PUBLIC_KEY&name=trellobo&response_type=token&scope=read,write&expiration=never
#
# Substitute the DEVELOPER_PUBLIC_KEY with the value oyu'll supply in TRELLO_API_KEY below. At the end of this process,
# You'll be told to give some key to the app, this is what you want to put in the TRELLO_API_ACCESS_TOKEN_KEY below.
#
# there are 5 environment variables that must be set for the trellobot to behave
# the way he is supposed to - 
#
# TRELLO_API_KEY : your Trello API developer key
# TRELLO_API_SECRET : your Trello API developer secret
# TRELLO_API_ACCESS_TOKEN_KEY : your Trello API access token key. See above how to generate it.
# TRELLO_BOT_CHANNEL : the name of the channel you want trellobot to live on, the server is freenode
# TRELLO_BOARD_ID : the trellobot looks at only one board and the lists on it, put its id here

$board = nil

include Trello
include Trello::Authorization
Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
OAuthPolicy.consumer_credential = OAuthCredential.new ENV['TRELLO_API_KEY'], ENV['TRELLO_API_SECRET']
OAuthPolicy.token = OAuthCredential.new ENV['TRELLO_API_ACCESS_TOKEN_KEY'], nil

def sync_board
  return $board.refresh! if $board
  $board = Trello::Board.find(ENV['TRELLO_BOARD_ID'])
end

def say_help(msg)
  msg.reply "I can tell you the open cards on the lists on your Trello board. Just address me with the name of the list (it's not case sensitive)."
  msg.reply "For example - trellobot: ideas"
  msg.reply "I also understand the these commands : "
  msg.reply "  -> 1. help - shows this!"
  msg.reply "  -> 2. sync - resyncs my cache with the board."
  msg.reply "  -> 3. lists - show me all the board list names"
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
      m.reply "I can't seem to get the list of ideas from Trello, sorry. Try here: https://trello.com/board/#{ENV['TRELLO_BOARD_ID']}" 
      bot.halt
    end
    
    # trellobot: what up?  <- The bit we are interested in is past the ':'
    parts = m.message.split(':',2)
    searchfor = parts[1].strip.downcase
    
    case searchfor
      when /lists/
        $board.lists.each { |l| 
          m.reply "  ->  #{l.name}"
        }
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
          list = $board.lists.detect { |l| l.name.casecmp(searchfor) == 0 }
          if list.nil?
            m.reply "There's no list called <#{searchfor}> on the board, #{m.user.nick}. Sorry."
          else
            cards = list.cards
            if cards.count == 0
              m.reply "Nothing doing on that list today, #{m.user.nick}."
            else
              ess = (cards.count == 1) ? "" : "s"
              m.reply "I have #{cards.count} card#{ess} today"
              inx = 1
              cards.each { |c|
                m.reply "  ->  #{inx.to_s}. #{c.name}"
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
