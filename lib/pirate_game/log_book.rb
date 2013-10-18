require 'thread'

class PirateGame::LogBook

  include Enumerable

  def initialize size = 10
    @mutex = Mutex.new
    @log_book = []
    @size = size
  end

  def add entry, author = 'unknown'
    @mutex.synchronize do
      @log_book << [entry, author]

      @log_book.shift if @log_book.size > @size
    end
  end

  def each
    return enum_for __method__ unless block_given?

    @log_book.each do |(entry, author)|
      yield [entry, author]
    end
  end

  def empty?
    @log_book.empty?
  end

  def length
    @log_book.length
  end
  alias_method :size, :length

end

