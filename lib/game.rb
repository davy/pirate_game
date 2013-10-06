Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do

  def draw_wave(top, frame, seed)
    size = 40
    t1 = frame + seed
    t2 = frame + seed*2
    offset_x = Math.sin(t1/10.0)*size
    offset_y = Math.cos(t2/18.0)*5
    stroke blue(top)
    strokewidth(2)
    nofill
    for i in (-1..10) do
      arc(i*size + offset_x, top + offset_y, size, size, 0, Shoes::PI)
    end
  end

  animate(30) do |frame|
    clear
    background aquamarine(100)
    title "Pirate Game!"

    top_of_waves = 230
    draw_wave(top_of_waves, frame, 30)
    draw_wave(top_of_waves+20, frame, 7)
    draw_wave(top_of_waves+40, frame, 42)
    draw_wave(top_of_waves+60, frame, -3)
    draw_wave(top_of_waves+80, frame, 22)
  end
end
