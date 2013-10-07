require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameClient < MiniTest::Unit::TestCase

  def setup
    @client = PirateGame::Client.new('foo', nil)
  end

  def test_initialize
    assert_empty @client.msg_log
  end

  def test_broadcast
    make_services

    @client.broadcast 'Hello'

    refute_empty @client.msg_log

    assert_includes @client.msg_log, 'Hello'
  end

  def make_services
    def @client.registered_services
      [['Davy', DRb.uri], ['Eric', DRb.uri]]
    end
  end
end
