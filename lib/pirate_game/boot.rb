require 'shoes/color'

module PirateGame
  module Boot

    DARK_COLOR = '#696969' #dimgray
    LIGHT_COLOR = '#dcdcdc' #gainsboro
    SKY_COLOR = '#00ffff' #aqua
    PUB_COLOR = '#52352b' #brown

    COLORS = {dark: DARK_COLOR, light: LIGHT_COLOR, sky: SKY_COLOR, pub: PUB_COLOR}

    BLUE_COLORS = [
                   Shoes::COLORS[:cornflowerblue],
                   Shoes::COLORS[:darkcyan],
                   Shoes::COLORS[:deepskyblue],
                   Shoes::COLORS[:mediumturquoise],
                   Shoes::COLORS[:steelblue],
                   Shoes::COLORS[:teal],
                   Shoes::COLORS[:turquoise]
    ]

    GREEN_COLORS = [Shoes::COLORS[:lightseagreen],
                    Shoes::COLORS[:mediumaquamarine],
                    Shoes::COLORS[:mediumseagreen],
                    Shoes::COLORS[:seagreen],
                    Shoes::COLORS[:teal]
    ]

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
end
