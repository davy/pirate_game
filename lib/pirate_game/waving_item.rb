##
# A WavingItem implements motion for a drawn shoes item.

class PirateGame::WavingItem

  ##
  # The speed of the item.  Either <code>:slow</code>, <code>:normal</code> or
  # <code>:fast</code>

  attr_accessor :speed

  ##
  # Creates a new WavingItem for the given +seed+ which was initially drawn at
  # +delta_x+ and +delta_y+ on the window.

  def initialize seed, delta_x, delta_y
    @seed = seed
    @delta_x = delta_x
    @delta_y = delta_y
    @speed = :normal
  end

  ##
  # Computes the current x and y rendering position for the animation +frame+.

  def waving_offset frame
    top_offset, left_offset =
      PirateGame::Boot.waving_offset frame, @seed, @delta_x, @delta_y, @speed
  end
end
