require 'shuttlecraft/mothership'

class GameMaster < Shuttlecraft::Mothership

  VERSION = '0.0.1'
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
        Stage.new @stage.level + 1, players
      else
        Stage.new 1, players
      end
  end

end

require 'stage'
