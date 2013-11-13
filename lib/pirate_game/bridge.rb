##
# The Bridge chooses which buttons appear on the stage screen and chooses
# random items from all items in the game.

class PirateGame::Bridge

  ##
  # The items on the current client's bridge.

  attr_accessor :items

  ##
  # All possible items in the current stage.

  attr_accessor :stage_items

  ##
  # Creates a new Bridge with the clients +items+ and all +stage_items+ for
  # the current stage.
  #
  # The +items+ appear as buttons in the ClientApp while the +stage_items+ are
  # used to create actions to display.

  def initialize(items, stage_items)
    @items       = items
    @stage_items = stage_items
  end

  ##
  # Chooses a random item from the stage_items.

  def sample_item
    item = @stage_items.sample

    # if we selected an item in the current bridge
    # reselect a new item 80% of the time
    if items.include?(item) && items.size < stage_items.size
      item = sample_item if rand > 0.2
    end

    return item
  end
end
