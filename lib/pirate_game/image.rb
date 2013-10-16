class PirateGame::Image

  def initialize shoes, image, top, left
    @shoes = shoes
    @image = image
    @top   = top
    @left  = left
  end

  def animate frame
    top_offset, left_offset = PirateGame::Boot.waving_offset frame, 0, 10, 4

    @ship.move @top + top_offset, @left + left_offset
  end

  def draw
    @ship = @shoes.image @image, top: @top, left: @left
  end

end

