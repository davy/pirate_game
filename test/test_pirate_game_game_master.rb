require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameGameMaster < MiniTest::Unit::TestCase

  def setup
    @game_master = PirateGame::GameMaster.new(name: 'Foo')
  end

  def test_initialize
    assert_nil @game_master.stage
  end

  def test_num_players_empty
    assert_equal 0, @game_master.num_players
  end

  def test_start
    @game_master.start

    assert_equal 1, @game_master.stage.level

    @game_master.start

    assert_equal 2, @game_master.stage.level
  end


end
