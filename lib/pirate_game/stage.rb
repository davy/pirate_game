require 'pirate_command'

##
# The Stage stores information about a particular stage of
# the game

class PirateGame::Stage

  ##
  # The number of actions completed.

  attr_accessor :actions_completed

  ##
  # A hash storing statistics on all the players

  attr_accessor :player_stats

  ##
  # All possible bridge items

  attr_accessor :all_items

  ##
  # The time that the stage was started

  attr_accessor :begin_time

  ##
  # The level of the stage.

  attr_accessor :level

  ##
  # The number of players

  attr_accessor :players

  ##
  # The number of items on each player's bridge

  ITEMS_PER_BRIDGE = 6

  ##
  # The duration of the stage

  DURATION = PirateGame::Boot.config["stage_duration"]

  IN_PROGRESS = 'In Progress'
  SUCCESS = 'Success'
  FAILURE = 'Failure'

  ##
  # Creates a new Stage for the +level+ and number of +players+
  #
  # The +level+ indicates stage difficulty, and +players+ is used
  # to determine how many bridge items to generate

  def initialize(level, players)
    @level = level
    @players = players
    @actions_completed = 0
    @player_stats = {}
    generate_all_items

    @begin_time = Time.now
  end

  ##
  # Creates a new Stage that is an incremented version of the
  # current stage.

  def increment
    PirateGame::Stage.new self.level + 1, self.players
  end

  ##
  # The time remaining in this stage

  def time_left
    [0, (begin_time + DURATION) - Time.now].max
  end

  ##
  # String indicating the status of the stage.
  #
  # Possible values are 'In Progress', 'Success' and 'Failure'
  def status
    if time_left > 0
      IN_PROGRESS
    else
      passed? ? SUCCESS : FAILURE
    end
  end

  ##
  # Returns true if the stage is in progress

  def in_progress?
    status == IN_PROGRESS
  end

  ##
  # Returns true if the stage is finished and successful

  def success?
    status == SUCCESS
  end

  ##
  # Returns true if the stage is finished and failed

  def failure?
    status == FAILURE
  end

  ##
  # Generates all the bridge items for the stage

  def generate_all_items
    @all_items = []

    while @all_items.length < @players*ITEMS_PER_BRIDGE
      thing = PirateCommand.thing
      @all_items << thing unless @all_items.include?(thing)
    end
    @boards = @all_items.each_slice(ITEMS_PER_BRIDGE).to_a
  end

  ##
  # Produces a unique bridge for a player in the game
  #
  # Should only be called once per player in the stage

  def bridge_for_player
    @boards.shift
  end

  ##
  # Adds an +action+ to the completed actions list, marked
  # as completed by +from+

  def complete action, from
    @actions_completed += 1
    @player_stats[from] ||= []
    @player_stats[from] << action
  end

  ##
  # The number of required actions for this stage
  # to be a success

  def required_actions
    @level * 2 + 1
  end

  ##
  # Returns true if enough actions have been
  # completed to mark the stage as passed, ie.
  # successful

  def passed?
    @actions_completed >= required_actions
  end

  ##
  # Returns a hash of stage statistics

  def rundown
    return if status == IN_PROGRESS

    rundown = {stage: @level, total_actions: @actions_completed}
    rundown[:player_breakdown] = {}

    @player_stats.each {|p,v| rundown[:player_breakdown][p] = v.size}

    rundown
  end

end
