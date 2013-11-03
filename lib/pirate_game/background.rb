class PirateGame::Background

  STATES = [:clear, :foggy]

  def initialize shoes, state=nil
    @shoes = shoes
    set_state state

    @items = []

    @items << PirateGame::Wave.new(@shoes, -20, 13)
    @items << PirateGame::Wave.new(@shoes, 0, 30)

    image = File.expand_path '../../../imgs/pirate_ship_sm.png', __FILE__

    @items << PirateGame::Image.new(@shoes, image, 66, 55)

    [[20, 7], [40, 42], [60, -3], [80, 22]].each do |top, seed|
      @items << PirateGame::Wave.new(@shoes, top, seed)
    end
  end

  def set_state state
    @state = state if STATES.include?(state)
    @state ||= :clear
  end

  def randomize_state
    case rand
    when 0.0..0.1
      @state = :foggy
    else
      @state = :clear
    end
  end

  def color
    case @state
    when :foggy
      @shoes.rgb(105, 138, 150, 180)
    else # :clear
      PirateGame::Boot::SKY_COLOR
    end
  end

  def draw
    randomize_state

    @shoes.background color unless foreground?

    @items.each do |item|
      item.draw
    end

    @extra_items = []

    yield if block_given?

    @extra_items.each do |item|
      item.draw
    end

    # doesn't draw over input items (buttons, text boxes, etc) >:(
    @shoes.background color if foreground?
  end

  def add_extra_item item
    @extra_items << item
  end

  def animate frame
    (@items + @extra_items).each do |item|
      item.animate frame
    end
  end

  def foreground?
    @state == :foggy
  end
end
