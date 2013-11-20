require 'shuttlecraft'
require 'thread'
require 'timeout'

##
# The PirateGame Client handles game logic for the client.

class PirateGame::Client < Shuttlecraft

  ##
  # States the game client can be in.

  STATES = [:select_game, :pub, :stage, :end]

  ##
  # The bridge holds the button set for the current stage.

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

  ##
  # The maximum allowed time for clicking a button after a command was issued.

  attr_accessor :completion_time

  ##
  # The command the client is waiting for

  attr_reader :current_action

  ##
  # Bucket for data being sent from game master

  attr_reader :slop_bucket

  ##
  # Creates a new Client.  The +options+ are the same as for Shuttlecraft.

  def initialize(options={})
    options[:protocol] ||= PirateGame::Protocol.default

    super(options.merge({:verbose => true}))

    set_state :select_game

    @bridge          = nil
    @command_start   = nil
    @command_thread  = nil
    @completion_time = PirateGame::Boot.config["action_duration"]
    @current_action  = nil
    @log_book        = PirateGame::LogBook.new

    @slop_bucket = {}
  end

  ##
  # The default pirate name

  def self.default_name
    "Blackbeard"
  end

  ##
  # Number of seconds left for completing the current command

  def action_time_left
    return 0 unless waiting?

    @command_start - Time.now + @completion_time
  end

  ##
  # Switches to state +state+, checking for validity.

  def set_state state
    raise RuntimeError, "invalid state #{state}" unless STATES.include? state

    @state = state
  end

  ##
  # Sends a button-clicked event to the tuple space with the +button+ that was
  # clicked.

  def clicked button
    renewer = Rinda::SimpleRenewer.new @completion_time

    @mothership.write [:button, button, Time.now.to_i, DRb.uri], renewer
  end

  ##
  # Requests a new action using +item+.  If no +item+ is given a random item
  # is chosen from the bridge.
  #
  # A separate thread is spawned to wait on action completion.

  def issue_command item=nil
    item ||= @bridge.sample_item if @bridge

    return unless item

    @command_thread = Thread.new do
      wait_for_action item
    end

    Thread.pass until @command_start # this should be a proper barrier

    @current_action = "#{PirateCommand.action} the #{item}"
  end

  ##
  # Registers the client with a GameMaster.

  def register
    set_state :pub
    super
  end

  ##
  # Starts a new game stage using the given sets of +my_items+ and
  # +all_items+.

  def start_stage my_items, all_items
    @bridge = PirateGame::Bridge.new my_items, all_items
    set_state :stage
  end

  ##
  # Returns to the pirate pub.  This is usually called after successful
  # completion of a stage.

  def return_to_pub
    @bridge = nil
    set_state :pub
  end

  ##
  # Ends the game.

  def end_game data
    set_state :end

    @slop_bucket[:end_game] = data
  end

  ##
  # Shows your teammates in this game.

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

  ##
  # Sends +msg+ to all other players.

  def broadcast(msg)
    each_client {|remote| remote.say(msg, @name) }
  end

  ##
  # Adds +msg+ to the log book (chat messages) which was sent from +name+.

  def say(msg, name)
    @log_book.add msg, name || 'unknown'
  end

  ##
  # A renewer for rinda tuples that only lives for the completion time of the
  # current action.

  def renewer
    PirateGame::TimeoutRenewer.new @completion_time
  end

  ##
  # Waits for an action (button press) involving +item+.  When one is seen it
  # inserts an action completion tuple into the tuple space for the game
  # master to pick up.

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

  ##
  # Are we waiting for the completion of an action?

  def waiting?
    @command_thread and @command_thread.alive? and @command_start
  end

end
