require 'shuttlecraft/protocol'

##
# The Protocol indicates how the PirateGame signals
# to other games via Rinda discovery

class PirateGame::Protocol < Shuttlecraft::Protocol

  ##
  # The default protocol

  def self.default
    @@default ||= self.new :PirateGame, "Pirate Game"
    @@default
  end

end
