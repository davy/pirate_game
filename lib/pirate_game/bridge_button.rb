class PirateGame::BridgeButton < PirateGame::WavingItem

  TOP = 150

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

  def animate frame
    top_offset, left_offset = waving_offset frame

    @button.move @top + top_offset, @left + left_offset
  end

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

