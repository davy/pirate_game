require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameGameMaster < MiniTest::Unit::TestCase

  def setup
    @client = PirateGame::Client.new name: 'user'

    @game_master = PirateGame::GameMaster.new(name: 'Foo')

    DRb.stop_service if DRb.primary_server
    DRb.start_service nil, @client
  end

  def test_initialize
    assert_nil @game_master.stage
  end

  def test_startable_eh

    # should not be startable when no players exist
    assert_equal 0, @game_master.num_players
    refute @game_master.startable?
    refute @game_master.start
    assert_nil @game_master.stage

    # should be startable after making services
    make_services

    assert @game_master.startable?
    assert @game_master.start

    # should not be startable when stage is failed
    @game_master.stage.begin_time = Time.at 0

    assert @game_master.stage.failure?
    refute @game_master.startable?
    refute @game_master.start

    # should be startable when stage is success
    10.times do
      @game_master.stage.complete 'test', 'test'
    end

    assert @game_master.stage.success?
    assert @game_master.startable?
  end

  def test_start
    make_services
    assert @game_master.start

    assert @game_master.stage
    assert_equal 1, @game_master.stage.level
    assert_equal 1, @game_master.stage_ary.length

    @game_master.stage.begin_time = Time.at 0
    10.times do
      @game_master.stage.complete 'test', 'test'
    end

    assert @game_master.start
    assert_equal 2, @game_master.stage.level
    assert_equal 2, @game_master.stage_ary.length

    assert_equal [1,2], @game_master.stage_ary.collect{|s| s.level}
  end

  def test_update
    assert_equal 0, @game_master.num_players
    assert_empty @game_master.player_names

    make_services

    assert_equal 0, @game_master.num_players
    assert_empty @game_master.player_names

    assert @game_master.update

    assert_equal 2, @game_master.num_players
    assert_equal %w[Davy Eric], @game_master.player_names.sort
  end

  def make_services
    def @game_master.read_registered_services
      [['Davy', DRb.uri], ['Eric', DRb.uri]]
    end
  end

end
