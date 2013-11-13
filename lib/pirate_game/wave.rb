##
# An animated ocean wave

class PirateGame::Wave < PirateGame::WavingItem

  ##
  # The possible colors of the wave

  COLORS = PirateGame::Boot::BLUE_COLORS + PirateGame::Boot::GREEN_COLORS

  ##
  # The default offset for a wave

  OFFSET = 210

  ##
  # The default size of the wave

  SIZE   = 40

  ##
  # Creates a new wave which will be drawn on the +shoes+ window at the given
  # +offset+ from the default OFFSET.

  def initialize shoes, offset
    super rand(40), SIZE, 5

    @shoes = shoes
    @top   = offset + OFFSET
    @arcs  = []
    @clear = @shoes.rgb 0, 0, 0, 0
  end

  ##
  # Repositions the wave for the given +frame+.

  def animate frame
    top_offset, left_offset = waving_offset frame

    @arcs.each do |arc, top, left|
      arc.move top + top_offset, left + left_offset
    end
  end

  ##
  # Draws the wave on the window.

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

