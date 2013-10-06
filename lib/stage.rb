require 'pirate_command'

class Stage
  attr_accessor :level, :players, :all_items

  ITEMS_PER_BRIDGE = 6

  def initialize(level, players)
    @level = level
    @players = players
    generate_all_items

    @begin_time = Time.now
  end

  def time_left
    (@begin_time + 120) - Time.now
  end

  def generate_all_items
    @all_items = []

    while @all_items.length < @players*ITEMS_PER_BRIDGE
      thing = PirateCommand.thing
      @all_items << thing unless @all_items.include?(thing)
    end
    @boards = @all_items.each_slice(ITEMS_PER_BRIDGE).to_a
  end

  def bridge_for_player
    @boards.shift
  end
end
