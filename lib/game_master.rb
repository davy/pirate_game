require 'shuttlecraft/mothership'

class GameMaster < Shuttlecraft::Mothership

  attr_accessor :stage

  def initialize(name)
    super(name)

    @stage = nil
  end

  def registrations_text
    registered_services.join(', ')
  end

  def start
    players = registered_services.length
    @stage =
      if @stage then
        PirateGame::Stage.new @stage.level + 1, players
      else
        PirateGame::Stage.new 1, players
      end
  end

end

