require 'shuttlecraft/mothership'

class PirateGame::GameMaster < Shuttlecraft::Mothership

  attr_accessor :stage

  def initialize(opts={})
    opts[:protocol] ||= PirateGame::Protocol.default

    super(opts)

    @stage = nil

    @action_watcher = create_action_watcher
  end

  def registrations_text
    "Num Players: #{num_players}\n" +
    registered_services.collect{|name,_| name}.join(', ')
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

  def num_players
    registered_services.length
  end

  def start
    @stage =
      if @stage then
        PirateGame::Stage.new @stage.level + 1, num_players
      else
        PirateGame::Stage.new 1, num_players
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
    @stage.complete action_array[1], action_array[3]
  end

end

