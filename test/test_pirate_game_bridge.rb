require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameBridge < MiniTest::Unit::TestCase

  def setup
    @bridge = PirateGame::Bridge.new(%w[Foo Bar], %w[Foo Bar Baz Buz])
  end

  def test_initialize
    assert_equal 2, @bridge.items.length
    assert_equal 4, @bridge.stage_items.length
  end
end
