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

  def startable?
    update
    (@stage.nil? || !@stage.in_progress?) &&
    @num_players >= MIN_PLAYERS && @num_players <= MAX_PLAYERS
  end

  def start
    return unless startable?
    @stage =
      if @stage then
        PirateGame::Stage.new @stage.level + 1, @num_players
      else
        PirateGame::Stage.new 1, @num_players
      end

    send_start_to_clients

    return true
  end

  def send_start_to_clients
    send_to_clients do |client|
      bridge = @stage.bridge_for_player
      client.start_stage(bridge)
    end
  end

  def send_return_to_pub_to_clients
    send_to_clients do |client|
      client.return_to_pub
    end
  end

  def send_end_game_to_clients
    send_to_clients do |client|
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
      puts "Got action #{action_array[1]}"
      @stage.complete action_array[1], action_array[3]
    end
  end

  ##
  # Retrieves the latest data from the TupleSpace.

  def update
    ret = super

    @num_players = registered_services.length

    @player_names = registered_services.map { |name,| name }

    ret
  end

  private

  def send_to_clients
    each_service_uri do |uri|
      begin
        remote = DRbObject.new_with_uri(uri)
        yield remote
      rescue DRb::DRbConnError
      rescue => e
        puts "hmm #{e.message}"
      end
    end
  end
end

