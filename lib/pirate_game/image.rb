class PirateGame::Image < PirateGame::WavingItem

  def initialize shoes, image, top, left
    super 0, 10, 4

    @shoes = shoes
    @image = image
    @top   = top
    @left  = left
  end

  def animate frame
    top_offset, left_offset = waving_offset frame

    @ship.move @top + top_offset, @left + left_offset
  end

  def draw
    @ship = @shoes.image @image, top: @top, left: @left
  end

end

