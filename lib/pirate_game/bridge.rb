class PirateGame::Bridge

  attr_accessor :items, :stage_items

  def initialize(items, stage_items)
    @items       = items
    @stage_items = stage_items
  end

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
