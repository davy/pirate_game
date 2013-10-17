class PirateGame::BridgeButton

  TOP = 150

  def initialize shoes, text, row, column, &click_action
    @shoes        = shoes
    @text         = text
    @row          = row
    @column       = column
    @click_action = click_action

    @button = nil
    @left   = nil
    @seed   = rand 90
    @top    = nil
  end

  def animate frame
    top_offset, left_offset = PirateGame::Boot.waving_offset frame, @seed, 10, 4

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

