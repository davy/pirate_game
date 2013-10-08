require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameClient < MiniTest::Unit::TestCase

  def setup
    @client = PirateGame::Client.new(name: 'foo')
  end

  def test_initialize
    assert_empty @client.msg_log
  end

  def test_broadcast
    make_services

    @client.broadcast 'Hello'

    refute_empty @client.msg_log

    assert_equal 2, @client.msg_log.length
    assert_includes @client.msg_log.collect{|msg, name| msg}, 'Hello'
    assert_includes @client.msg_log.collect{|msg, name| name}, 'Davy'
  end

  def test_get_name_from_uri
    make_services

    assert_equal 'Davy', @client.get_name_from_uri(DRb.uri)
  end

  def make_services
    def @client.registered_services
      [['Davy', DRb.uri], ['Eric', DRb.uri]]
    end
  end
end
