require 'shuttlecraft/protocol'

class PirateGame::Protocol < Shuttlecraft::Protocol

  def self.default
    @@default ||= self.new :PirateGame, "Pirate Game"
    @@default
  end

end
