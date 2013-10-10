require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameBridge < MiniTest::Unit::TestCase

  def setup
    @bridge = PirateGame::Bridge.new(%w[Foo Bar])
  end

  def test_initialize
    assert_equal 2, @bridge.items.length
  end
end
