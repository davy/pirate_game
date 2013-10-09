require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameGameMaster < MiniTest::Unit::TestCase

  def setup
    @game_master = PirateGame::GameMaster.new(name: 'Foo')
  end

  def test_initialize
    assert_nil @game_master.stage
  end

  def test_startable_eh
    assert_equal 0, @game_master.num_players
    refute @game_master.startable?

    @game_master.start

    assert_nil @game_master.stage

    make_services

    refute @game_master.startable?

    @game_master.update

    assert @game_master.startable?
  end

  def test_start
    make_services
    @game_master.update

    @game_master.start

    assert_equal 1, @game_master.stage.level

    @game_master.start

    assert_equal 2, @game_master.stage.level
  end

  def test_update
    assert_equal 0, @game_master.num_players
    assert_empty @game_master.player_names

    make_services

    assert_equal 0, @game_master.num_players
    assert_empty @game_master.player_names

    @game_master.update

    assert_equal 2, @game_master.num_players
    assert_equal %w[Davy Eric], @game_master.player_names.sort
  end

  def test_update_eh
    assert @game_master.update?

    refute @game_master.update?
  end

  def make_services
    def @game_master.registered_services
      [['Davy', DRb.uri], ['Eric', DRb.uri]]
    end
  end

end
