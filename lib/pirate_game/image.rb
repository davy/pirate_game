##
# An Image displays an image on the screen and can move like other
# WavingItems.

class PirateGame::Image < PirateGame::WavingItem

  ##
  # Creates a new WavingItem for the given +image+ that will be drawn at the
  # +top+ and +left+ offsets.
  #
  # All images wave together on the screen.  There is no randomness to their
  # motion by default.

  def initialize shoes, image, top, left
    super 0, 10, 4

    @shoes = shoes
    @image = image
    @top   = top
    @left  = left
  end

  ##
  # Redraws the image for the given animation +frame+.

  def animate frame
    top_offset, left_offset = waving_offset frame

    @ship.move @top + top_offset, @left + left_offset
  end

  ##
  # Draws the image on the window.

  def draw
    @ship = @shoes.image @image, top: @top, left: @left
  end

end

