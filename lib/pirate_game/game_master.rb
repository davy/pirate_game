require 'shuttlecraft/mothership'

class PirateGame::GameMaster < Shuttlecraft::Mothership


  MIN_PLAYERS = 1 # for now
  MAX_PLAYERS = 4

  attr_accessor :stage

  ##
  # Number of players in the game.  Call #update to refresh

  attr_reader :num_players

  ##
  # Names of players in the game.  Call #update to refresh

  attr_reader :player_names

  def initialize(opts={})
    opts[:protocol] ||= PirateGame::Protocol.default

    super(opts)

    @last_update  = Time.at 0
    @num_players  = 0
    @player_names = []
    @stage        = nil
    @stage_ary    = []

    @action_watcher = create_action_watcher
  end

  def registrations_text
    "Num Players: #{@num_players}\n#{@player_names.join(', ')}"
  end

  def stage_info
    return unless @stage

    info = "Stage #{@stage.level}: \n"
    if @stage.in_progress?
      info << "Actions: #{@stage.actions_completed.size}\n"
      info << "Time Left: #{@stage.time_left.to_i} seconds\n"
    else
      info << "Status: #{@stage.status}\n"

      rundown = @stage.rundown

      info << "Total Actions: #{rundown[:total_actions]}\n"

      rundown[:player_breakdown].each do |player_uri, actions|
        info << "#{player_uri}: #{actions}\n"
      end

    end

    info
  end

  def allow_registration?
    return (@stage.nil? && @num_players < MAX_PLAYERS)
  end

  def startable?
    update!
    return (@stage.nil? || @stage.success?) &&
           @num_players >= MIN_PLAYERS &&
           @num_players <= MAX_PLAYERS
  end

  def increment_stage
    if @stage
      @stage.increment
    else
      PirateGame::Stage.new 1, @num_players
    end
  end

  def start
    return unless startable?

    @stage_ary << @stage if @stage
    @stage = increment_stage

    return true
  end

  def send_stage_info_to_clients
    if @stage.in_progress?
      send_start_to_clients

    elsif @stage.success?
      send_return_to_pub_to_clients

    elsif @stage.failure?
      send_end_game_to_clients
    end
  end

  def send_start_to_clients
    each_client do |client|
      bridge = @stage.bridge_for_player
      client.start_stage(bridge, @stage.all_items)
    end
  end

  def send_return_to_pub_to_clients
    each_client do |client|
      client.return_to_pub
    end
  end

  def send_end_game_to_clients
    each_client do |client|
      client.end_game
    end
  end

  def create_action_watcher
    Thread.new do
      loop do
        handle_action @ts.take([:action, nil, nil, nil])
      end
    end
  end

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

end

