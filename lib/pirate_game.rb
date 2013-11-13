##
# Pirate Game is a
# {Spaceteam}[http://www.sleepingbeastgames.com/spaceteam/]-like game with a
# pirate theme that illustrates distributed programming concepts using DRb and
# Rinda.

module PirateGame

  ##
  # The version of PirateGame you are running

  VERSION = '0.0.1'

end

require 'pirate_game/animation'
require 'pirate_game/background'
require 'pirate_game/boot'
require 'pirate_game/waving_item'
require 'pirate_game/bridge'
require 'pirate_game/bridge_button'
require 'pirate_game/client'
require 'pirate_game/client_app'
require 'pirate_game/game_master'
require 'pirate_game/image'
require 'pirate_game/log_book'
require 'pirate_game/master_app'
require 'pirate_game/protocol'
require 'pirate_game/stage'
require 'pirate_game/timeout_renewer'
require 'pirate_game/wave'

