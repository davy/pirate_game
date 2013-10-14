require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameTimeoutRenewer < MiniTest::Unit::TestCase

  def test_renew
    r = PirateGame::TimeoutRenewer.new 5

    assert_equal 5, r.renew

    assert_equal true, r.renew
  end

end

