class PirateGame::Wave < PirateGame::WavingItem

  COLORS = PirateGame::Boot::BLUE_COLORS + PirateGame::Boot::GREEN_COLORS

  OFFSET = 230
  SIZE   = 40

  def initialize shoes, top
    super rand(40), SIZE, 5

    @shoes = shoes
    @top   = top + OFFSET
    @arcs  = []
    @clear = @shoes.rgb 0, 0, 0, 0
  end

  def animate frame
    top_offset, left_offset = waving_offset frame

    @arcs.each do |arc, top, left|
      arc.move top + top_offset, left + left_offset
    end
  end

  def draw
    for i in (-3..12) do
      for j in [0,2,4] do
        color_index = (@seed + j) % COLORS.size
        @shoes.fill @clear
        @shoes.stroke COLORS[color_index]
        @shoes.strokewidth 3
        arc_dif = (j/360.0)*Shoes::TWO_PI

        top  = i * SIZE - j
        left = @top + j

        arc = @shoes.arc(i * SIZE - j, @top + j, SIZE + j, SIZE + j,
                         0 + arc_dif, Shoes::PI - arc_dif)

        @arcs << [arc, top, left]
      end
    end
  end

end

