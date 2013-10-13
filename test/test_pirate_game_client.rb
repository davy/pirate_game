require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameClient < MiniTest::Unit::TestCase

  def setup
    @ts = Rinda::TupleSpace.new

    @client = PirateGame::Client.new(name: 'foo')

    @client.instance_variable_set :@mothership, @ts
  end

  def test_initialize
    assert_empty @client.msg_log
  end

  def test_clicked
    make_services

    @client.clicked 'Test'

    tuple = @ts.read [:button, nil, nil, nil]

    assert_equal :button, tuple.shift
    assert_equal 'Test',  tuple.shift
    assert_includes (Time.now.to_i - 1..Time.now.to_i), tuple.shift
    assert_equal DRb.uri, tuple.shift
  end

  def test_teammates
    make_services

    assert_includes @client.teammates, 'Davy'
    assert_includes @client.teammates, 'Eric'
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

  def test_wait_for_action
    @client.clicked 'Test'

    @client.wait_for_action 'Test'

    action = @ts.read [:action, nil, nil, nil]

    action.shift

    assert_equal 'Test',  action.shift
    assert_kind_of Time,  action.shift
    assert_equal DRb.uri, action.shift
  end

  def make_services
    def @client.registered_services
      [['Davy', DRb.uri], ['Eric', DRb.uri]]
    end
  end
end
