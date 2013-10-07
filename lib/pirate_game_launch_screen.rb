Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do

  def draw_wave(top, frame, seed)
    size = 40

    offset_x, offset_y = generate_waving_x_y_offsets(frame, seed, size, 5)

    wave_colors = [blue(256), cornflowerblue(256), darkcyan(256), deepskyblue(256), mediumturquoise(256), steelblue(256), teal(256), turquoise(256)]
    green_wave_colors = [lightseagreen(256), mediumaquamarine(256), mediumseagreen(256), seagreen(256), teal(256)]
    stroke blue(256)
    nofill
    for i in (-1..10) do
      for j in [0,2,4] do

        colors = wave_colors + green_wave_colors
        #colors = green_wave_colors
        #colors = [wave_colors.first]
        color_index = (seed + j) % colors.size
        stroke colors[color_index]
        strokewidth(3)
        arc_dif = (j/360.0)*Shoes::TWO_PI
        arc(i*size + offset_x - j, top + j + offset_y, size + j, size + j, 0 + arc_dif, Shoes::PI - arc_dif)
      end
    end
  end

  def draw_ship(frame)
    ship_top = 66
    ship_left = 55
    offset_x, offset_y = generate_waving_x_y_offsets(frame, 0, 10, 4)

    ship_file = File.dirname(__FILE__) + '/../imgs/pirate_ship_sm.png'
    ship = image(ship_file, top: ship_top + offset_y, left: ship_left + offset_x)
  end

  def generate_waving_x_y_offsets(frame, seed, delta_x, delta_y)
    t1 = frame + seed
    t2 = frame + seed * 2
    offset_x = Math.sin(t1/10.0) * delta_x
    offset_y = Math.cos(t2/18.0) * delta_y

    return offset_x, offset_y
  end

  animate(30) do |frame|
    clear
    background aquamarine(256)
    title "Pirate Game!"

    top_of_waves = 230

    draw_wave(top_of_waves, frame, 30)

    draw_ship(frame)

    draw_wave(top_of_waves+20, frame, 7)
    draw_wave(top_of_waves+40, frame, 42)
    draw_wave(top_of_waves+60, frame, -3)
    draw_wave(top_of_waves+80, frame, 22)
  end
end
