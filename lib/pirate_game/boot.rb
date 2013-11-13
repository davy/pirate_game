require 'shoes/color'
require 'json'

##
# The Boot holds utility methods for starting the game.

module PirateGame::Boot

  ##
  # A dim gray color

  DARK_COLOR = '#696969'

  ##
  # This color is called "gainsboro"

  LIGHT_COLOR = '#dcdcdc'

  ##
  # The sky is aqua

  SKY_COLOR = '#00ffff'

  ##
  # The pub is the brown of the grog stains on the floor

  PUB_COLOR = '#52352b'

  ##
  # Colors of the game

  COLORS = {dark: DARK_COLOR, light: LIGHT_COLOR, sky: SKY_COLOR, pub: PUB_COLOR}

  ##
  # Various blue colors used for waves

  BLUE_COLORS = [
    Shoes::COLORS[:cornflowerblue],
    Shoes::COLORS[:darkcyan],
    Shoes::COLORS[:deepskyblue],
    Shoes::COLORS[:mediumturquoise],
    Shoes::COLORS[:steelblue],
    Shoes::COLORS[:teal],
    Shoes::COLORS[:turquoise]
  ]

  ##
  # Various green colors used for waves

  GREEN_COLORS = [
    Shoes::COLORS[:lightseagreen],
    Shoes::COLORS[:mediumaquamarine],
    Shoes::COLORS[:mediumseagreen],
    Shoes::COLORS[:seagreen],
    Shoes::COLORS[:teal]
  ]

  ##
  # The pirate game configuration file.

  def self.config_file # :nodoc:
    File.expand_path '../../../config.json', __FILE__
  end

  ##
  # Loads the pirate game configuration.

  def self.config_hash # :nodoc:
    begin
      JSON.parse(open(self.config_file).read)
    rescue
      {"stage_duration" => 30, "action_duration" => 8}
    end
  end

  ##
  # The pirate game configuration

  def self.config
    @config ||= self.config_hash
    @config
  end

  ##
  # Computes the offset for waving motion of drawn items like the waves and
  # buttons.
  #
  # The +frame+ is the animation frame, used to compute the offset.  The
  # +seed+ allows randomization of the starting position of motion.  +delta_x+
  # and +delta_y+ are the coordinates of the item at rest.  The +speed+
  # adjusts how fast the item moves.  Valid values are <code>:normal</code> or
  # <code>:fast</code>.
  #
  # Returns the x and y offsets of the item for the current frame.

  def self.waving_offset(frame, seed, delta_x, delta_y, speed = :normal)
    t1 = frame + seed
    t2 = frame + seed * 2
    vel = 10.0

    case speed
    when :slow
      vel = 20.0
    when :fast
      vel = 2.0
      delta_x *= 2
      delta_y *= 2
    end

    offset_x = Math.sin(t1/vel) * delta_x
    offset_y = Math.cos(t2/vel) * delta_y

    return offset_x, offset_y
  end
end
