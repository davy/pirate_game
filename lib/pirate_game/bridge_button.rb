##
# A BridgeButton draws and animates a moving button that should be hard to
# click.

class PirateGame::BridgeButton < PirateGame::WavingItem

  ##
  # The default offset for bridge buttons

  TOP = 150 # :nodoc:

  ##
  # Creates a new BridgeButton that will be drawn using the +shoes+ app.  The
  # button will say +text+ and be drawn at +row+ and +column+.  If a block is
  # given, it will be invoked when clicked.

  def initialize shoes, text, row, column, &click_action
    super rand(90), 10, 4

    @shoes        = shoes
    @text         = text
    @row          = row
    @column       = column
    @click_action = click_action

    @button = nil
    @left   = nil
    @top    = nil
  end

  ##
  # Redraws the button for the give animation +frame+.

  def animate frame
    top_offset, left_offset = waving_offset frame

    @button.move @top + top_offset, @left + left_offset
  end

  ##
  # Draws the button on the window.

  def draw
    width = @shoes.app.width
    chunk = width / 6

    # something is wrong in my head, these are switched
    @top  = chunk / 3 + 2 * @column * chunk
    @left = TOP + @row * 40

    @button = @shoes.button @text, &@click_action
    @button.move @left, @top
  end

end

