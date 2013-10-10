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
    return unless update?

    services = registered_services

    @num_players = services.length

    @player_names = services.map { |name,| name }
  end

  ##
  # A game is only updatable if it hasn't been updated in the last two
  # seconds.  This prevents DRb message spam.

  def update?
    now = Time.now

    return false if @last_update + 2 > now

    @last_update = now
  end

end

