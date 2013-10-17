require 'shoes'

##
# An animation that resets the client application if a DRb::DRbConnError is
# raised during animation.

class PirateGame::Animation < Shoes::Animation

  ##
  # See Shoes::Animation for details

  def initialize app, opts, blk
    blk = wrap_block blk

    super app, opts, blk
  end

  ##
  # Wraps +block+ in an exception handler that switches to the
  # select_game_screen.

  def wrap_block block # :nodoc:
    proc do |*args|
      begin
        block.call(*args)
      rescue DRb::DRbConnError
        @app.state = :select_game

        @app.select_game_screen
      end
    end
  end

end

