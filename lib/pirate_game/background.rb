##
# Implements the background of a game client window

class PirateGame::Background

  ##
  # The background weather.

  WEATHER = [:clear, :foggy, :windy]

  ##
  # Creates a new game background which will draw using the +shoes+ instance.
  #
  # You can also set the +weather+ for the background which must be one of the
  # WEATHER items.

  def initialize shoes, weather=nil
    @shoes = shoes
    set_weather weather

    @items = []

    @items << PirateGame::Wave.new(@shoes, 0)
    @items << PirateGame::Wave.new(@shoes, 20)

    image = File.expand_path '../../../imgs/pirate_ship_sm.png', __FILE__

    @items << PirateGame::Image.new(@shoes, image, 66, 55)

    [40, 60, 80, 100].each do |top|
      @items << PirateGame::Wave.new(@shoes, top)
    end
  end

  ##
  # Sets the background +weather+ which must be one of the given WEATHER
  # items.

  def set_weather weather
    @weather = weather if WEATHER.include?(weather)
    @weather ||= :clear
  end

  ##
  # Chooses a random weather for the Background.

  def randomize_weather
    case rand
    when 0.0..0.1
      @weather = :foggy
    when 0.2..0.3
      @weather = :windy
    else
      @weather = :clear
    end
  end

  ##
  # Adjust the movement speed of the items in the Background.

  def send_speed_to_items # :nodoc:
    case @weather
    when :windy
      all_items.each {|item| item.speed = :fast}
    end
  end

  ##
  # Returns all items in the Background.

  def all_items # :nodoc:
    @items + @extra_items
  end

  ##
  # Returns the color which is drawn behind all other items in the Background.

  def color # :nodoc:
    case @weather
    when :foggy
      @shoes.rgb(105, 138, 150, 180)
    else # :clear, :windy
      PirateGame::Boot::SKY_COLOR
    end
  end

  ##
  # Draws the Background.

  def draw
    randomize_weather

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

  ##
  # Adds extra items to the Background for drawing.  Items must respond to
  # #draw and #animate.

  def add_extra_item item
    @extra_items << item
  end

  ##
  # Updates the items in the background for the current +frame+.

  def animate frame
    all_items.each do |item|
      item.animate frame
    end
  end

  ##
  # Returns true if a foreground should be drawn over the items in the
  # Background.

  def foreground?
    @weather == :foggy
  end
end
