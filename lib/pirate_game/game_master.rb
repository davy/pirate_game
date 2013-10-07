require 'shuttlecraft/mothership'

class PirateGame::GameMaster < Shuttlecraft::Mothership

  attr_accessor :stage

  def initialize(name)
    super(name)

    @stage = nil
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

end

