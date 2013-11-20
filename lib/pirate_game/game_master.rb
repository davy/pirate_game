require 'shuttlecraft/mothership'

##
# The game master coordinates players including chat, moving players through
# the stages of a pirate game and deciding which actions are in play for the
# current stage.

class PirateGame::GameMaster < Shuttlecraft::Mothership

  ##
  # You can play with yourself because one player is all that's needed!

  MIN_PLAYERS = 1 # for now

  ##
  # Four is the maximum number of players.

  MAX_PLAYERS = 4

  ##
  # States of the game

  STATES = [:pending, :startable, :playing, :ended]

  ##
  # The current game master stage.

  attr_accessor :stage

  ##
  # The history of stages played.

  attr_accessor :stage_history

  ##
  # The state of the game. See STATES.

  attr_reader :state

  ##
  # Number of players in the game.  Call #update to refresh

  attr_reader :num_players

  ##
  # Names of players in the game.  Call #update to refresh

  attr_reader :player_names

  ##
  # Creates a new game master.  +options+ are the same as for
  # Shuttlecraft::Mothership

  def initialize(options={})
    options[:protocol] ||= PirateGame::Protocol.default

    super(options.merge({:verbose => true}))

    set_state :pending

    @last_update   = Time.at 0
    @num_players   = 0
    @player_names  = []
    @stage         = nil
    @stage_history = []

    @action_watcher = create_action_watcher
  end

  ##
  # Text showing the number and names of players currently registered.

  def registrations_text
    "Num Players: #{@num_players}\n#{@player_names.join(', ')}\n"
  end

  ##
  # Text showing the state of the current stage.

  def stage_info
    return unless @stage

    info = "Stage #{@stage.level}: \n"
    if @stage.in_progress?
      info << "Actions: #{@stage.actions_completed}\n"
      info << "Time Left: #{@stage.time_left.to_i} seconds\n"
    else
      info << "Status: #{@stage.status}\n"

      rundown = @stage.rundown

      info << "Actions: #{rundown[:total_actions]}\n"

      rundown[:player_breakdown].each do |player_uri, actions|
        info << "#{player_uri}: #{actions}\n"
      end

    end

    info
  end

  ##
  # Statistics about the game progress.

  def game_info
    return if @stage_history.empty?

    info = "Game Rundown:\n"
    gr = game_rundown

    info << "Total Actions: #{gr[:total_actions]}\n"

    gr[:player_breakdown].each do |player_uri, actions|
      info << "#{player_uri}: #{actions}\n"
    end

    info
  end

  ##
  # Creates a summary of stage and player activity for the current game.

  def game_rundown
    return {} if @stage_history.empty?

    rundown = {
      :total_stages => @stage_history.length,
      :total_actions =>
        @stage_history.map { |stage| stage.actions_completed }.reduce(:+),
      :player_breakdown => {}}

    for stage in @stage_history
      stage.player_stats.each_pair do |key, value|
        rundown[:player_breakdown][key] ||= 0
        rundown[:player_breakdown][key] += value.size
      end
    end

    rundown
  end

  ##
  # True if more players can join the game

  def allow_registration?
    return (@stage.nil? && @num_players < MAX_PLAYERS)
  end

  ##
  # True if the game has enough players to start

  def startable?
    update!
    return (@stage.nil? || @stage.success?) &&
           @num_players >= MIN_PLAYERS &&
           @num_players <= MAX_PLAYERS
  end

  ##
  # Advances the game to the next stage.

  def increment_stage
    @stage =
      if @stage
        @stage.increment
      else
        PirateGame::Stage.new 1, @num_players
      end

    @stage_history << @stage
    @stage
  end

  ##
  # This is called from Mothership when a new client joins.

  def on_registration
    set_state :startable if startable?
  end

  ##
  # Starts the current stage

  def start
    return unless startable?

    increment_stage

    return true
  end

  ##
  # Delivers stage progress information to clients.

  def send_stage_info_to_clients
    if @stage.in_progress?
      set_state :playing
      send_start_to_clients

    elsif @stage.success?
      set_state :startable
      send_return_to_pub_to_clients

    elsif @stage.failure?
      set_state :ended
      send_end_game_to_clients
    end
  end

  ##
  # Delivers the client's items and all items to all clients.

  def send_start_to_clients
    each_client do |client|
      bridge = @stage.bridge_for_player
      client.start_stage(bridge, @stage.all_items)
    end
  end

  ##
  # Instructs clients to return to the pub.

  def send_return_to_pub_to_clients
    each_client do |client|
      client.return_to_pub
    end
  end

  ##
  # Instructs clients that they have failed and should be ashamed of their
  # failure.

  def send_end_game_to_clients
    each_client do |client|
      client.end_game game_rundown
    end
  end

  ##
  # Watches for completed actions by the clients.

  def create_action_watcher
    Thread.new do
      loop do
        handle_action @ts.take([:action, nil, nil, nil])
      end
    end
  end

  ##
  # Updates the stage with a completed action.

  def handle_action action_array
    if @stage && @stage.in_progress?
      @stage.complete action_array[1], action_array[3]
    end
  end

  ##
  # Retrieves the latest data from the TupleSpace.

  def update
    ret = super
    return if ret.nil?

    @num_players = @registered_services_ary.length

    @player_names = @registered_services_ary.map { |name,| name }

    ret
  end

  private

  ##
  # Sets the current game state to +state+

  def set_state state
    @state = state if STATES.include? state
  end

end

