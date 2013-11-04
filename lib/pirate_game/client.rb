require 'shuttlecraft'
require 'thread'
require 'timeout'

class PirateGame::Client < Shuttlecraft

  STATES = [:select_game, :pub, :stage, :end]

  attr_reader :bridge

  ##
  # Log of messages sent

  attr_reader :log_book

  ##
  # The state of the client.  See STATES.

  attr_reader :state

  ##
  # The time the last command was issued

  attr_reader :command_start

  attr_accessor :completion_time

  ##
  # The command the client is waiting for

  attr_reader :current_action

  ##
  # Bucket for data being sent from game master

  attr_reader :slop_bucket

  def initialize(opts={})
    opts[:protocol] ||= PirateGame::Protocol.default

    super(opts)

    self.state = :select_game

    @bridge          = nil
    @command_start   = nil
    @command_thread  = nil
    @completion_time = 10
    @current_action  = nil
    @log_book        = PirateGame::LogBook.new

    @slop_bucket = {}
  end

  def action_time_left
    return 0 unless waiting?

    @command_start - Time.now + @completion_time
  end

  def state= state
    raise RuntimeError, "invalid state #{state}" unless STATES.include? state

    @state = state
  end

  def clicked button
    renewer = Rinda::SimpleRenewer.new @completion_time

    @mothership.write [:button, button, Time.now.to_i, DRb.uri], renewer
  end

  def issue_command item=nil
    item ||= @bridge.sample_item if @bridge

    return unless item

    @command_thread = Thread.new do
      wait_for_action item
    end

    Thread.pass until @command_start # this should be a proper barrier

    @current_action = "#{PirateCommand.action} the #{item}"
  end

  def register
    self.state = :pub
    super
  end

  def start_stage(bridge, all_items)
    @bridge = PirateGame::Bridge.new(bridge, all_items)
    self.state = :stage
  end

  def return_to_pub
    @bridge = nil
    self.state = :pub
  end

  def end_game data
    self.state = :end

    @slop_bucket[:end_game] = data
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
    each_client {|remote| remote.say(msg, @name) }
  end

  def say(msg, name)
    @log_book.add msg, name || 'unknown'
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
