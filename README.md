# pirate_game

* https://github.com/davy/pirate_game

## Description

## TODO

Game Master
 * Stage
   * creates bridge for each player
   * provides list of total bridge items
   * Actions completed
   * Missed actions
   * Difficulty level
   * Time left
   * booty collected
 * Fails game
 * Global random events
   * fog, rain, clouds, hurricane
 * Entire team cooperative events (stretch goal?)
   * navy raid, merchant ship?, kraken
   * watches tuplespace for action messages
   * will need to know who sent message, so we can trigger when all users check in
 * Cleanup expired messages


Game

* Particular activity
    * Displays text on current game screen
    * Watches tuplespace for action message
        * tuple: [:action, 'Action Text', Time.now, DRB.uri]
    * Timer that counts down
        * sends action failed message

Game Display

Stage in progress
 * Backdrop (sunny, clouds, rain, hurricane)
    * nice rolling waves
 * Bridge (which also moves)
    * Array of buttons for items assigned by game master
 * Wheel (stretch goal)
    * 15 degrees port!
 * Progress bar for time left?
 * Progress bar for booty collected?
 * Cannon for raids
 
 Stage complete
    * Return to port and drink rum 
    * chat?

Character creation
 * beard style, hat style, parrot color, eyepatch


## Credits

Pirate Ship image used under [CC by-nc-sa
3.0](http://creativecommons.org/licenses/by-nc-sa/3.0/) from
http://sweetclipart.com/pirate-ship-design

## Developers

After checking out the source, run:

    $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

## License

(The MIT License)

Copyright (c) Davy Stevenson, Eric Hodel

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

