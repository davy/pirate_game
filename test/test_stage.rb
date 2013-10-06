require 'minitest/autorun'
require 'stage'

class TestStage < MiniTest::Unit::TestCase

  def setup
    @stage = Stage.new 1, 3
  end

  def test_time_left
    assert_operator 120, :>, @stage.time_left
  end

  def test_generate_all_items
    assert_equal 18, @stage.all_items.uniq.length
  end

  def test_bridge_for_player
    bridge = @stage.bridge_for_player

    assert_equal 6, bridge.length

    @stage.bridge_for_player
    @stage.bridge_for_player

    assert_nil @stage.bridge_for_player
  end

end
