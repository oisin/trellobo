## Trellobo
This is a simple IRC bot written using [cinch](http://github.com/cinchrb/cinch). The motivation for writing this was that people using the *dublinjs* IRC channel can address the bot to get a list of the current ideas for talks that are stored as cards in a Trello board. 

This incarnation is generalized a little, and it can serve as a (simple) general purpose IRC bot that will communicate with Trello. Configuration of API key, channel name and URLs are driven thru ENV. 

The Trello API is used in readonly mode in this code, so all you need to access is your developer key, providing the board is public. Trellobot simply uses [rest-client](https://github.com/archiloque/rest-client) for this purpose.

At some point in Trellobot's life, it will gain the capability to add cards to lists on a Trello board. That needs a little more development, with addition of Oauth capability to the Trellobot server.

Trellobot understands the commands *help* and *sync*. Anything else it interprets as the name of a list on the target board that has been configured. If you send a private message containing *quit*, then Trellobot will disconnect from the server (and exit). Depending on how you have it deployed, it may very well respawn at that point.

## Environment Vars
Trellobot needs the following in the ENV to operate:
<table>
  <tr><th>ENV</th><th>Content</th></tr>
  <tr><td>TRELLO_API_KEY</td><td>Your Trello developer API key</td></tr>
  <tr><td>TRELLO_BOARD_API_URL</td><td>The API URL for your board</td></tr>
  <tr><td>TRELLO_BOARD_HUMAN_URL</td><td>The human-friendly URL for your board</td></tr>
  <tr><td>TRELLO_BOT_CHANNEL</td><td>The channel that trellobot should join</td></tr>
</table>  

## Where do I get the API URL for my board?
I used the magic of _curl_ for this particular job of discovery. The Trello API covers a lot, [as you can read in the beta docs](https://trello.com/docs/api/index.html) and sometimes it's not immediately obvious where to grab on to find a particular piece of information. 

If you know your username, you can list all your boards, with their ids. You then use the id to get API URL of the board. In this example, I'm listing all _public_ boards of the _dublinjavascript_ member and limiting the data returned on the boards to just the _name_ field (nice idea on the filtering guys) of the board. The id comes back for free, of course.

<code>
61%  curl https://api.trello.com/1/members/dublinjavascript?key=TRELLO\_API\_KEY\&boards=public\&board_fields=name
{
    "id": _the id of the member_,
    "fullName": "Dublin JavaScript",
    "username": "dublinjavascript",
    "gravatar": _the gravatar id for the profile pic_,
    "bio": "",
    "url": "https://trello.com/dublinjavascript",
    "boards": [
        {
            **"id": "4f05b412cf33c09c016a90df",**
            "name": "Dublin Javascript Talks"
        }
    ]
}
</code>

The boldfaced **id** up there is the piece you are looking for - put this into a URL like this

<code>
  https://api.trello.com/1/boards/**4f05b412cf33c09c016a90df**/lists
</code>

and that is your TRELLO\_BOARD\_API\_URL.

