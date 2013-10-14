require 'shuttlecraft'
require 'thread'

class PirateGame::Client < Shuttlecraft

  attr_reader :msg_log, :bridge

  attr_accessor :completion_time

  ##
  # The command the client is waiting for

  attr_reader :current_action

  def initialize(opts={})
    opts[:protocol] ||= PirateGame::Protocol.default

    super(opts)

    @bridge          = nil
    @command_thread  = nil
    @completion_time = 30
    @current_action  = nil
    @msg_log         = []
    @msg_log_mutex   = Mutex.new
  end

  def clicked button
    @mothership.write [:button, button, Time.now.to_i, DRb.uri], renewer
  end

  def issue_command action
    @command_thread = Thread.new do
      wait_for_action action
    end

    @current_action = action
  end

  def start_stage(items)
    @bridge = PirateGame::Bridge.new(items)
  end

  def return_to_pub
    @bridge = nil
  end

  def teammates
    registered_services.collect{|name,_| name}
  end

  def perform_action action
    if @mothership
      @mothership.write [:action, action, Time.now, DRb.uri]
    end
  end

  def broadcast(msg)
    for _, uri in registered_services
      begin
        remote = DRbObject.new_with_uri(uri)
        remote.say(msg, DRb.uri)
      rescue DRb::DRbConnError
      end
    end
  end

  def say(msg, from)
    @msg_log_mutex.synchronize do
      name = get_name_from_uri(from)
      @msg_log << [msg, name || 'unknown']
    end
    begin
      remote = DRbObject.new_with_uri(from)
      remote.message_reciept(@name)
    rescue DRb::DRbConnError
    end
  end

  def message_reciept(from)
  end

  def get_name_from_uri(uri)
    from = registered_services.detect{|n, u| uri == u}
    from[0] if from
  end

  def renewer
    Rinda::SimpleRenewer.new @completion_time
  end

  def wait_for_action action
    now = Time.now.to_i

    _, _, _, from =
      @mothership.read [:button, action, (now...now + 30), nil], renewer

    @mothership.write [:action, action, Time.now, from]
  rescue Rinda::RequestExpiredError
  ensure
    @current_action = nil
  end

  def waiting?
    @command_thread and @command_thread.alive?
  end

end
