class PirateGame::Background

  STATES = [:clear, :foggy, :windy]

  def initialize shoes, state=nil
    @shoes = shoes
    set_state state

    @items = []

    @items << PirateGame::Wave.new(@shoes, 0)
    @items << PirateGame::Wave.new(@shoes, 20)

    image = File.expand_path '../../../imgs/pirate_ship_sm.png', __FILE__

    @items << PirateGame::Image.new(@shoes, image, 66, 55)

    [40, 60, 80, 100].each do |top|
      @items << PirateGame::Wave.new(@shoes, top)
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
    when 0.2..0.3
      @state = :windy
    else
      @state = :clear
    end
  end

  def send_speed_to_items
    case @state
    when :windy
      all_items.each {|item| item.speed = :fast}
    end
  end

  def all_items
    @items + @extra_items
  end

  def color
    case @state
    when :foggy
      @shoes.rgb(105, 138, 150, 180)
    else # :clear, :windy
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

    send_speed_to_items
  end

  def add_extra_item item
    @extra_items << item
  end

  def animate frame
    all_items.each do |item|
      item.animate frame
    end
  end

  def foreground?
    @state == :foggy
  end
end
