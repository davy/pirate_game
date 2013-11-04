class PirateGame::WavingItem

  attr_accessor :speed

  def initialize seed, delta_x, delta_y

    @seed = seed
    @delta_x = delta_x
    @delta_y = delta_y
    @speed = :normal
  end

  def waving_offset frame
    top_offset, left_offset =
      PirateGame::Boot.waving_offset frame, @seed, @delta_x, @delta_y, @speed
  end
end
