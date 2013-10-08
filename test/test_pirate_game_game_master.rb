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

  def test_num_players
    make_services

    assert_equal 2, @game_master.num_players
  end

  def test_startable_eh
    assert_equal 0, @game_master.num_players
    refute @game_master.startable?

    @game_master.start

    assert_nil @game_master.stage

    make_services

    assert @game_master.startable?
  end

  def test_start
    make_services

    @game_master.start

    assert_equal 1, @game_master.stage.level

    @game_master.start

    assert_equal 2, @game_master.stage.level
  end

  def make_services
    def @game_master.registered_services
      [['Davy', DRb.uri], ['Eric', DRb.uri]]
    end
  end

end
