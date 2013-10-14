##
# A renewer that expires when its timeout is up

class PirateGame::TimeoutRenewer

  include DRbUndumped

  ##
  # The timeout for the renewer (after first renewal)

  attr_reader :timeout

  ##
  # Creates a renewer that will expire after the +timeout+ passes.

  def initialize timeout
    @timeout = timeout
    @renew = true
  end

  def renew # :nodoc:
    return true unless @renew

    @renew = false

    @timeout
  end

end

