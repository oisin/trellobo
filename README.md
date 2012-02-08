## Trellobo
This is a simple IRC bot written using [cinch](http://github.com/cinchrb/cinch). The motivation for writing this was so that people using the *dublinjs* IRC channel could address the bot to get a list of the current ideas for Javascript subject matter talks that are stored as cards in a Trello board. 

This incarnation is generalized a little, and it can serve as a (simple) general purpose IRC bot that will communicate with Trello. Configuration of API key and secret, channel name and URLs are driven thru ENV. 

The Trello API is used in readonly mode in this code, so all you need to access is your developer key, providing the board is public. Trellobot uses the [Trello API Ruby wrapper](https://github.com/jeremytregunna/ruby-trello) for this purpose.

At some point in Trellobot's life, it will gain the capability to add cards to lists on a Trello board. That needs a little more development, with addition of Oauth capability to the Trellobot server.

Trellobot understands the commands *help*, *lists* and *sync*. Anything else it interprets as the name of a list on the target board that has been configured. If you send a private message containing *quit*, accompanied by a passphrase, then Trellobot will disconnect from the server (and exit). Depending on how you have it deployed, it may very well respawn at that point, for example if you run it as a [Heroku](http://www.heroku.com) dyno. 

## Environment Vars
Trellobot needs the following in the ENV to operate:
<table>
  <tr><th>ENV</th><th>Content</th></tr>
  <tr><td>TRELLO_API_KEY</td><td>Your Trello developer API key</td></tr>
  <tr><td>TRELLO_API_SECRET</td><td>Your Trello developer API secret</td></tr>
  <tr><td>TRELLO_API_ACCESS_TOKEN_KEY</td><td>Your Trello API access token key</td></tr>
  <tr><td>TRELLO_BOARD_ID</td><td>The ID for your board</td></tr>
  <tr><td>TRELLO_BOT_CHANNEL</td><td>The channel that trellobot should join - form is #channel - don't forget quotes for shell protection!</td></tr>
  <tr><td>TRELLO_BOT_SERVER</td><td>The server the trellobot should connect to, defaults to <em>irc.freenode.net</em></td></tr>
  <tr><td>TRELLO_BOT_NAME</td><td>The name the trellobot should use, defaults to <em>trellobot</em></td></tr>
  <tr><td>TRELLO_BOT_QUIT_CODE</td><td> Passcode to cause trellobot to quit - defaults to empty</td></tr>
</table>

## Where do I get an API key and API secret?
Log in as a Trello user and visit this URL to get a key and secret allocated: https://trello.com/1/appKey/generate

## Where do I get an API Access Token Key?
You will need an access token to use ruby-trello 0.3.0 or higher, which trellobo depends on. To get it, you'll need to go to this URL:

https://trello.com/1/connect?key=TRELLO_API_KEY&name=trellobo&response_type=token&scope=read,write&expiration=never

At the end of this process, You'll be told to give some key to the app, this is what you want to put in the TRELLO_API_ACCESS_TOKEN_KEY

## Where do I get the BOARD ID for my board?

The simplest way to get the id of your board is to 

1. Browse to it on the trello website
2. Observe the URL; it should look something like https://trello.com/board/welcome-board/4e6a8095efa69909ba007382
3. The id of your board is the 24-digit hex number at the end of the URL.  In this case, it's `4e6a8095efa69909ba007382`

Initially, I used the magic of _curl_ for this particular job of discovery. The Trello API covers a lot, [as you can read in the beta docs](https://trello.com/docs/api/index.html) and sometimes it's not immediately obvious where to grab on to find a particular piece of information. 

If you know your username, you can list all your boards, with their ids. You then use the id to get API URL of the board. In this example, I'm listing all _public_ boards of the _dublinjavascript_ member and limiting the data returned on the boards to just the _name_ field (nice idea on the filtering guys) of the board. The id comes back for free, of course.

<pre><code>
61%  curl https://api.trello.com/1/members/dublinjavascript?key=TRELLO_API_KEY\&boards=public\&board_fields=name
{
    "id": _the id of the member_,
    "fullName": "Dublin JavaScript",
    "username": "dublinjavascript",
    "gravatar": _the gravatar id for the profile pic_,
    "bio": "",
    "url": "https://trello.com/dublinjavascript",
    "boards": [
        {
            "id": "4f05b412cf33c09c016a90df",           ---- this is what you want
            "name": "Dublin Javascript Talks"
        }
    ]
}
</code></pre>

The *boards[0]['id']* up there is the piece you are looking for - put this into the `TRELLO_BOARD_ID` environment variable.

## Notes

I've seen one weirdness on Heroku where a dyno running Trellobot appeared to disappear off into the dyno grid and keep running, even after it was stopped. This resulted in duplicate bots on the channel. After a couple of days the zombie bot disappeared of its own accord.

## Pull Requests

Pull requests are welcome :)

[@oisin](http://twitter.com/oisin)