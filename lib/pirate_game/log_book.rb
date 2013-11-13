require 'thread'

##
# The LogBook stores a limited record of chat messages for a client in the
# pirate pub.
#
# When the log book is full the oldest entries are discarded so the new one
# can fit.

class PirateGame::LogBook

  include Enumerable

  ##
  # Creates a new LogBook that will contain up to +size+ entries.

  def initialize size = 10
    @mutex = Mutex.new
    @log_book = []
    @size = size
  end

  ##
  # Adds a new +entry+ to the log book that was written by +author+.

  def add entry, author = 'unknown'
    @mutex.synchronize do
      @log_book << [entry, author]

      @log_book.shift if @log_book.size > @size
    end
  end

  ##
  # Enumerates the entries in the log book.

  def each
    return enum_for __method__ unless block_given?

    @log_book.each do |(entry, author)|
      yield [entry, author]
    end
  end

  ##
  # Returns true when there are no items in the log book.

  def empty?
    @log_book.empty?
  end

  ##
  # Returns the number of items in the log book.

  def length
    @log_book.length
  end

  alias_method :size, :length

end

