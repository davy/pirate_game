require 'shuttlecraft/mothership'

class PirateGame::GameMaster < Shuttlecraft::Mothership

  attr_accessor :stage

  def initialize(name)
    super(name)

    @stage = nil

    @action_watcher = create_action_watcher
  end

  def registrations_text
    "Num Players: #{num_players}\n" +
    registered_services.collect{|name,_| name}.join(', ')
  end

  def stage_info
    return unless @stage
    "Stage #{@stage.level}: \n" +
    "Actions Completed: #{@stage.actions_completed.size}\n" +
    "Time Left: #{@stage.time_left.to_i} seconds\n" +
    "Status: #{@stage.status}"
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

