require 'minitest/autorun'
require 'pirate_game'

class TestPirateGameLogBook < MiniTest::Unit::TestCase

  def setup
    @log_book = PirateGame::LogBook.new
  end

  def test_initialize
    assert_empty @log_book
  end

  def test_add
    @log_book.add 'Day One', 'Davy'

    assert_equal 1, @log_book.length
    assert_equal ['Day One', 'Davy'], @log_book.first
  end

  def test_maintain_size
    10.times do |i|
      @log_book.add "Day #{i+1}", 'Davy'
    end

    assert_equal 10, @log_book.length

    @log_book.add "Another Day", 'Eric'

    assert_equal 10, @log_book.length
    assert_equal ['Day 2', 'Davy'], @log_book.first
    assert @log_book.detect{|msg,auth| auth == 'Eric'}
  end
end
