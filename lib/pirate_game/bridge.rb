class PirateGame::Bridge

  attr_accessor :items, :stage_items

  def initialize(items, stage_items)
    @items       = items
    @stage_items = stage_items
  end
end
