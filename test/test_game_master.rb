require 'minitest/autorun'
require 'game_master'

class TestGameMaster < MiniTest::Unit::TestCase

  def setup
    @game_master = GameMaster.new('Foo')
  end

  def test_initialize
    assert_nil @game_master.stage
  end

  def test_registrations_text_empty
    assert_empty @game_master.registrations_text
  end

  def test_start
    @game_master.start

    assert_equal 1, @game_master.stage.level

    @game_master.start

    assert_equal 2, @game_master.stage.level
  end


end
