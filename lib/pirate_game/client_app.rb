require 'shuttlecraft'
require 'pirate_game'

class PirateGame::Client < Shuttlecraft

  attr_reader :msg_log

  def initialize(name, app)
    super(name)
    @app = app
    @msg_log = []
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
    @msg_log << msg
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

begin
  @my_app = Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do

    @client = nil

    def launch_screen
      clear do
        background black
        title "What's your name", stroke: white
        el = edit_line text: 'Name' do |s|
          @name = s.text
        end
        button('launch') {
          @client = PirateGame::Client.new(@name, @my_app)
          select_game_screen
        }
      end
    end

    def select_game_screen
      clear do
        background black
        title "Select Game", stroke: white

        stack do
          motherships = @client.find_all_motherships

          if motherships.empty?
            subtitle "No Games Found", stroke: white
          else
            subtitle "Select Game", stroke: white
          end
          for mothership in motherships
            button(mothership[:name]) {|b|
              begin
                @client.initiate_communication_with_mothership(b.text)
              rescue
                select_game_screen
              end
              display_screen
            }
          end

          button('rescan') {
            select_game_screen
          }
        end
      end
    end

    def display_screen
      clear do
        stack :margin => 20 do
          title "Client #{@client.name}"

          stack do @status = para end

          @registered = nil
          @updating_area = stack
          @msg_stack = stack
        end

        animate(5) {
          if @client

            detect_registration_change

            if @registered
              @registrations.replace registrations_text

              @msg_stack.clear do
                for msg in @client.msg_log
                  para msg
                end
              end
            end
          end
        }
      end
    end

    def detect_registration_change
      if @registered != @client.registered?
        @registered = @client.registered?
        @status.replace "#{"Not " unless @registered}Registered"
        @updating_area.clear do
          if @registered
            button("Unregister") { unregister }

            el = edit_line

            button("Send") {
              @client.broadcast(el.text)
            }
            stack do
              para 'Registered Services:'
              @registrations = para
            end
          else
            button("Register")    { register }
          end
        end
      end
    end



    def register
      @client.register if @client
    end

    def unregister
      @client.unregister if @client
    end

    def registrations_text
      @client.registered_services.join(', ') if @client
    end

    launch_screen
  end
ensure
  @my_app.unregister if @my_app
end
