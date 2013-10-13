require 'pirate_game'

module PirateGame
  Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do

    def draw_wave(top, frame, seed)
      size = 40

      offset_x, offset_y = Boot.generate_waving_x_y_offsets(frame, seed, size, 5)

      nofill
      colors = Boot::BLUE_COLORS + Boot::GREEN_COLORS

      for i in (-1..10) do
        for j in [0,2,4] do

          color_index = (seed + j) % colors.size
          stroke colors[color_index]
          strokewidth 3
          arc_dif = (j/360.0)*Shoes::TWO_PI
          arc(i*size + offset_x - j, top + j + offset_y, size + j, size + j, 0 + arc_dif, Shoes::PI - arc_dif)
        end
      end
    end

    def draw_ship(frame, top, left, file=nil)
      offset_x, offset_y = Boot.generate_waving_x_y_offsets(frame, 0, 10, 4)

      file ||= '/../imgs/pirate_ship_sm.png'
      ship_file = File.dirname(__FILE__) + file
      ship = image(ship_file, top: top + offset_y, left: left + offset_x)
    end

    animate(30) do |frame|
      clear
      background Boot::COLORS[:sky]
      stack margin: 20 do
        title "Pirate Game!"
      end

      top_of_waves = 230

      draw_wave(top_of_waves, frame, 30)

      draw_ship(frame, 66, 55)

      draw_wave(top_of_waves+20, frame, 7)
      draw_wave(top_of_waves+40, frame, 42)
      draw_wave(top_of_waves+60, frame, -3)
      draw_wave(top_of_waves+80, frame, 22)
    end

  end
end
