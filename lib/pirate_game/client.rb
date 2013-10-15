require 'shuttlecraft'
require 'thread'
require 'timeout'

class PirateGame::Client < Shuttlecraft

  STATES = [:select_game, :pub, :stage, :end]

  attr_reader :state, :msg_log, :bridge

  ##
  # The time the last command was issued

  attr_reader :command_start

  attr_accessor :completion_time

  ##
  # The command the client is waiting for

  attr_reader :current_action

  def initialize(opts={})
    opts[:protocol] ||= PirateGame::Protocol.default

    super(opts)

    set_state :select_game

    @bridge          = nil
    @command_start   = nil
    @command_thread  = nil
    @completion_time = 10
    @current_action  = nil
    @msg_log         = []
    @msg_log_mutex   = Mutex.new
  end

  def action_time_left
    return 0 unless waiting?

    @command_start - Time.now + @completion_time
  end

  def set_state state
    if STATES.include? state
      @state = state
    end
  end

  def clicked button
    renewer = Rinda::SimpleRenewer.new @completion_time

    @mothership.write [:button, button, Time.now.to_i, DRb.uri], renewer
  end

  def issue_command item=nil
    item ||= @bridge.stage_items.sample

    @command_thread = Thread.new do
      wait_for_action item
    end

    Thread.pass until @command_start # this should be a proper barrier

    @current_action = "#{PirateCommand.action} the #{item}"
  end

  def register
    set_state :pub
    super
  end

  def start_stage(bridge, all_items)
    @bridge = PirateGame::Bridge.new(bridge, all_items)
    set_state :stage
  end

  def return_to_pub
    @bridge = nil
    set_state :pub
  end

  def end_game
    set_state :end
  end

  def teammates
    registered_services.collect{|name,_| name}
  end

  #
  # Sends action message to Game Master indicating
  # that action has been successfully performed
  def perform_action item, time, from
    if @mothership
      @mothership.write [:action, item, time, from]
    end
  end

  def broadcast(msg)
    each_service_uri do |uri|
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
    PirateGame::TimeoutRenewer.new @completion_time
  end

  def wait_for_action item
    @command_start = Time.now
    now = @command_start.to_i

    Thread.pass

    from = nil

    Timeout.timeout @completion_time do
      _, _, _, from =
        @mothership.read [:button, item, (now...now + 30), nil], renewer
    end

    perform_action item, Time.now, from

  rescue Rinda::RequestExpiredError, Timeout::Error
  ensure
    @command_thread = nil
    @command_start  = nil
    @current_action = nil
  end

  def waiting?
    @command_thread and @command_thread.alive? and @command_start
  end

end
