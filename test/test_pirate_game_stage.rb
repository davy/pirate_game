require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameStage < MiniTest::Unit::TestCase

  def setup
    @stage = PirateGame::Stage.new 1, 3
  end

  def test_increment
    @inc = @stage.increment

    assert_equal 2, @inc.level
    assert_equal @stage.players, @inc.players
  end

  def test_time_left
    assert_operator 30, :>=, @stage.time_left
    assert_operator 28, :<, @stage.time_left
  end

  def test_status_in_progress
    assert_equal 'In Progress', @stage.status
    assert @stage.in_progress?
    refute @stage.failure?
    refute @stage.success?
  end

  def test_status_success
    10.times { @stage.complete 'foo', 'bar' }

    complete_stage

    assert_equal 'Success', @stage.status
    assert @stage.success?
    refute @stage.in_progress?
    refute @stage.failure?
  end

  def test_status_failed
    complete_stage

    assert_equal 'Failure', @stage.status
    assert @stage.failure?
    refute @stage.success?
    refute @stage.in_progress?
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

  def test_actions_completed
    assert_equal 0, @stage.actions_completed

    @stage.complete 'Foo', 'from bob'

    assert_equal 1, @stage.actions_completed
  end

  def test_required_actions
    assert_equal 10, @stage.required_actions

    @stage = PirateGame::Stage.new(5, 4)

    assert_equal 29, @stage.required_actions

    @stage = PirateGame::Stage.new(10, 2)

    assert_equal 25, @stage.required_actions
  end

  def test_stage_passed_eh
    refute @stage.passed?

    9.times do
      @stage.complete 'foo', 'bar'
    end

    refute @stage.passed?

    @stage.complete 'for', 'the win'

    assert @stage.passed?
  end

  def test_rundown
    10.times { @stage.complete 'foo', 'bar' }

    assert_nil @stage.rundown

    complete_stage

    rundown = {:stage => 1, :total_actions => 10, :player_breakdown => {'bar' => 10}}

    assert_equal rundown, @stage.rundown
  end

  def complete_stage
    def @stage.begin_time
      Time.now - 360
    end
  end

end
