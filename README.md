# pirate_game

* https://github.com/davy/pirate_game

## Description

## INSTALL

 * Install jruby, bundler
 * clone shoes4 - commit 7d0a1eefea601917dd01419b14ded2812d0acb9f
 * [Follow shoes4 install instructions](https://github.com/shoes/shoes4)
 * gem install shoes-4.0.0.pre1
 * alias shoes4='/path/to/shoes4/bin/shoes'
 * gem install pirate_game
   * gem install pirate_command
   * gem install shuttlecraft

## RUN GAME

 * One person runs game_master
   * Run ringserver
   * shoes4 game_master
 * Players run game_client
   * shoes4 game_client


## DONE
Game Master



## TODO

Installation Instructions
 * create gist, tweet it out
Gemfile?

Game Master
 * Stage
   * **X creates bridge for each player**
   * **X provides list of total bridge items**
   * **X Actions completed / booty collected**
   * **X Difficulty level**
   * **X Time left**
 * Watcher threads
   * **X watches for activity messages and sends to stage**
   * Cleans up expired button messages?
 * **Ends game**
   * Provides final statistics on player activity
   * Booty collected, cannons fired, info on each player?
 * Entire team cooperative events (stretch goal?)
   * navy raid, merchant ship?, kraken
   * watches tuplespace for action messages
   * will need to know who sent message, so we can trigger when all users check in

Client

 * **X Registers with game**
 * Each client indicates when ready to begin stage
   * **X Game Master then notifies clients stage has begun**
   * ^ currently this is just a force button in GM
 * 
 * Particular action
    * **X Generates "#{action} the #{thing}" message**
      * thing comes from list of available bridge items
      * action is simply PirateCommand.action, doesn't mean anything, just makes game more fun
    * **X Displays text on current game screen**
      * Need to make this look better. Banner? Moves across screen? 
    * **X Watches tuplespace for button message**
    * **X Timer that counts down**
        * Would be nice to show progress bar. Tried to implement but am getting SWT errors   
    * **X When message is received sends action message to GM**

Game Display

Stage in progress
 * Backdrop (sunny, clouds, rain, hurricane)
    * nice rolling waves
    * weather (**Xsunny**, **Xfoggy**, clouds, rain, hurricane?)
 * Bridge
    * **X Array of buttons for items assigned by game master**
    * **X gentle swaying action**
    * Sways change based on background state?
 * Wheel (stretch goal)
    * 15 degrees port!
 * Progress bar for time left?
 * Progress bar for booty collected?
 * Cannon for raids?
 
Stage complete
 * **X Return to port and drink rum**
 * **X Chat**

Character creation
 * beard style, hat style, parrot color, eyepatch


## Credits

Pirate Ship image used under [CC by-nc-sa
3.0](http://creativecommons.org/licenses/by-nc-sa/3.0/) from
http://sweetclipart.com/pirate-ship-design

Jolly Roger Flag image used under [CC by-nc-sa 
3.0](http://creativecommons.org/licenses/by-nc-sa/3.0/) 
from http://freestock.ca/flags_maps_g80-jolly_roger_pirate_grunge_flag_p1022.html

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

