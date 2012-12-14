This project is a fork of http://github.com/osin/trellobo. It fix some small bugs, add support for ssl and passworded channels, changed harcoded bot name to env variable etc. Also add this operations with cards:
  1. card add this is a card - creates a new card named: \'this is a card\' in a list defined in the TRELLO_ADD_CARDS_LIST env variable or if it\'s not present in a list named To Do"
  2. card <id> comment this is a comment on card <id> - creates a comment on the card with short id equal to <id>"
  3. card <id> move to Doing - moves the card with short id equal to <id> to the list Doing"
  4. card <id> add member joe - assign joe to the card with short id equal to <id>."
  5. cards joe - return all cards assigned to joe"
  6. card <id> view joe@email.com - sends an email to joe@email.com with the content of the card with short id equal to <id>"

Configuration variables:
TRELLO_API_KEY : your Trello API developer key
TRELLO_API_SECRET : your Trello API developer secret
TRELLO_API_ACCESS_TOKEN_KEY : your Trello API access token key. See above how to generate it.
TRELLO_BOARD_ID : the trellobot looks at only one board and the lists on it, put its id here
TRELLO_BOT_QUIT_CODE : passcode to cause trellobot to quit - defaults to none
TRELLO_BOT_CHANNEL : the name of the channel you want trellobot to live on
TRELLO_BOT_CHANNEL_KEY : the password of the channel you want trellobot to live on. Optional
TRELLO_BOT_NAME : the name for the bot, defaults to 'trellobot'
TRELLO_BOT_SERVER : the server to connect to, defaults to 'irc.freenode.net'

TRELLO_SSL : if ssl is required set this variable to "true" if not, do not set it at all. Optional
TRELLO_SSL_PORT : if ssl is used set this variable to the port number that should be used. Optional
TRELLO_ADD_CARDS_LIST : all cards are added at creation time to a default list. Set this variable to the
TRELLO_MAIL_ADDRESS : address of the mail server used to send the cards
TRELLO_MAIL_PORT : port of the mail server used to send the cards
TRELLO_MAIL_AUTHENTICATION : type of authentication of the mail server used to send the cards
TRELLO_MAIL_USERNAME : username in the mail server used to send the cards
TRELLO_MAIL_PASSWORD : password for the username in the mail server used to send the cards
TRELLO_MAIL_ENABLE_STARTTLS_AUTO : set tu true if the mail server uses tls, false otherwise
