module PirateGame
  class ClientApp

    def self.run
      @my_app = Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do

        require 'pirate_game/shoes4_patch'

        @client = nil

        def launch_screen
          clear do
            background Boot::COLORS[:dark]
            stack margin: 20 do
              title "What's your name", stroke: Boot::COLORS[:light]
              edit_line text: 'Name' do |s|
                @name = s.text
              end
              button('launch') {
                @client = Client.new(name: @name)
              }
            end
            @state_watcher = animate(5) {
              watch_state
            }
          end
        end

        def watch_state
          return if @client.nil?
          return if @state == @client.state

          @state = @client.state

          case @state
          when :select_game
            select_game_screen
          when :pub
            pub_screen
          when :stage
            stage_screen
          when :end
            end_screen
          end
        end

        def select_game_screen
          clear do
            background Boot::COLORS[:dark]
            stack :margin => 20 do
              title "Choose Game", stroke: Boot::COLORS[:light]

              stack do
                motherships = @client.find_all_motherships

                if motherships.empty?
                  subtitle "No Games Found", stroke: Boot::COLORS[:light]
                else
                  subtitle "Select Game", stroke: Boot::COLORS[:light]
                end

                for mothership in motherships
                  draw_mothership_button mothership
                end

                button('rescan') {
                  select_game_screen
                }
              end
            end
          end
        end

        def pub_screen
          clear do
            background Boot::COLORS[:pub]
            stack :margin => 20 do
              title "Pirate Pub", stroke: Boot::COLORS[:light]
              tagline "Welcome #{@client.name}", stroke: Boot::COLORS[:light]

              stack do @status = para end

              @registered = nil
              @updating_area = stack
              @chat_room = stack
            end

            # checks for registration changes
            # updates chat messages
            @pub_animation = animate(5) {
              if @client
                draw_updating_area

                draw_chat_room
              end
            }
          end
        end

        def stage_screen
          @pub_animation.remove if @pub_animation

          clear do
            background Boot::COLORS[:sky]
            stack :margin => 20 do
              title PirateCommand.exclaim!, stroke: Boot::COLORS[:dark]

              draw_command_box

              @button_flow = flow do
                for item in @client.bridge.items
                  button(item) {|b| @client.perform_action b.text }
                end
              end
            end
          end
        end

        def end_screen
          clear do
            background Boot::COLORS[:dark]
            stack margin: 20 do
              title "END OF GAME", stroke: Boot::COLORS[:light]
            end
          end
        end

        ##
        # If the registration state has changed, yields to the block.

        def detect_registration_change
          return if @client.registered? == @registered

          @registered = @client.registered?

          @status.replace "#{"Not " unless @registered}Registered"

          yield
        end

        def draw_chat_room
          if @registered
            @chat_room.clear do
              if @client.waiting? then
                para 'Click "Test Button"'
              else
                para 'AVAST!!'
                @client.issue_command 'Test Button'
              end

              caption "Pub Chat: #{@client.teammates.join(', ')}", stroke: Boot::COLORS[:light]
              for msg, name in @client.msg_log
                para "#{name} said: #{msg}", stroke: Boot::COLORS[:light]
              end
            end
          end
        end

        def draw_command_box
          current_action = nil
          time_left      = nil

          flow do
            time_left = para

            current_action = para @client.current_action
          end

          animate 1 do
            @client.issue_command 'a' unless @client.waiting?

            time_left.replace '%d' % @client.action_time_left
            current_action.replace @client.current_action
          end
        end

        def draw_updating_area
          detect_registration_change do
            @updating_area.clear do
              if @registered
                button("Test Action") { @client.perform_action 'Test Action' }
                button("Test Button") { @client.clicked 'Test Button' }
                button("Test Stage")  do
                  @client.start_stage 'a'..'f'; stage_screen
                end

                flow do
                  el = edit_line

                  button("Send") {
                    unless el.text.empty?
                      @client.broadcast(el.text)
                      el.text = ''
                    end
                  }
                end
              else
                button("Register")    { register }
              end
            end
          end
        end

        def draw_mothership_button mothership
          button(mothership[:name]) {|b|
            begin
              @client.initiate_communication_with_mothership(b.text)
              @client.register
            rescue
              select_game_screen
            end
          }
        end

        def register
          @client.register if @client
        end

        def unregister
          @client.unregister if @client
        end

        launch_screen
      end
    ensure
      @my_app.unregister if @my_app
    end
  end
end
