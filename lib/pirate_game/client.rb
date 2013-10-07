require 'shuttlecraft'
require 'thread'

class PirateGame::Client < Shuttlecraft

  attr_reader :msg_log

  def initialize(name, app)
    super(name)
    @app = app
    @msg_log = []
    @msg_log_mutex = Mutex.new
  end

  def broadcast(msg)
    for name,uri in registered_services
      begin
        remote = DRbObject.new_with_uri(uri)
        remote.say(msg, DRb.uri)
      rescue DRb::DRbConnError
      end
    end
  end

  def say(msg, from)
    @msg_log_mutex.synchronize do
      @msg_log << msg
    end
    begin
      remote = DRbObject.new_with_uri(from)
      remote.message_reciept(@name)
    rescue DRb::DRbConnError
    end
  end

  def message_reciept(from)
    puts "reciept from #{from}"
  end
end
