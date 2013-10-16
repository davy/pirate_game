require 'pirate_game'

module PirateGame

  class Image

    def initialize shoes, image, top, left
      @shoes = shoes
      @image = image
      @top   = top
      @left  = left
    end

    def animate frame
      top_offset, left_offset =
        Boot.generate_waving_x_y_offsets(frame, 0, 10, 4)

      @ship.move @top + top_offset, @left + left_offset
    end

    def draw
      @ship = @shoes.image @image, top: @top, left: @left
    end

  end

  class Wave

    COLORS = Boot::BLUE_COLORS + Boot::GREEN_COLORS

    OFFSET = 230

    SIZE   = 40

    def initialize shoes, top, seed
      @shoes = shoes
      @top   = top + OFFSET
      @seed  = seed

      @arcs  = []
      @clear = @shoes.rgb 0, 0, 0, 0
    end

    def animate frame
      top_offset, left_offset =
        Boot.generate_waving_x_y_offsets(frame, @seed, SIZE, 5)

      @arcs.each do |arc, top, left|
        arc.move top + top_offset, left + left_offset
      end
    end

    def draw
      for i in (-1..10) do
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

  Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do
    def make_items
      items = []

      items << Wave.new(self, 0, 30)

      image = File.expand_path '../../imgs/pirate_ship_sm.png', __FILE__

      items << Image.new(self, image, 66, 55)

      [[20, 7], [40, 42], [60, -3], [80, 22]].each do |top, seed|
        items << Wave.new(self, top, seed)
      end

      items
    end

    def draw items
      clear

      background Boot::COLORS[:sky]

      stack margin: 20 do
        title "Pirate Game!"
      end

      items.each do |item|
        item.draw
      end
    end

    def launch_screen
      items = make_items

      draw items

      animate(30) do |frame|
        items.each do |item|
          item.animate frame
        end
      end
    end

    launch_screen
  end
end
