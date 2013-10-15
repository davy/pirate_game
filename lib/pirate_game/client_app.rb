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

                subtitle_text =
                  motherships.empty? ? "No Games Found" : "Select Game"

                subtitle subtitle_text, stroke: Boot::COLORS[:light]

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
          @stage_animation.remove if @stage_animation

          clear do
            background Boot::COLORS[:pub]
            stack :margin => 20 do
              title "Pirate Pub", stroke: Boot::COLORS[:light]
              tagline "Welcome #{@client.name}", stroke: Boot::COLORS[:light]

              stack do @status = para '', stroke: Boot::COLORS[:light] end

              @registered = nil
              @updating_area = stack
              @feedback_area = stack
              stack do
                @chat_title = tagline 'Pub Chat', stroke: Boot::COLORS[:light]
                @chat_input = flow
                @chat_messages = stack
              end
            end

            # checks for registration changes
            # updates chat messages
            @pub_animation = animate(5) {
              if @client

                # updates screen only when registration state changes
                update_on_registration_change

                # updates screen, runs every time
                update_feedback_area
                update_chat_room
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

              stack do
                @instruction = flow margin: 20

                flow do
                  for item in @client.bridge.items
                    button(item) {|b| @client.clicked b.text }
                  end
                end
              end

            end

            @stage_animation = animate(1) {
              @client.issue_command unless @client.waiting?

              @instruction.clear do
                para @client.action_time_left.to_i, stroke: Boot::COLORS[:dark]
                para @client.current_action, stroke: Boot::COLORS[:dark]
              end
            }
          end
        end

        def end_screen
          @pub_animation.remove if @pub_animation
          @stage_animation.remove if @stage_animation

          clear do
            background Boot::COLORS[:dark]
            stack margin: 20 do
              title "END OF GAME", stroke: Boot::COLORS[:light]

              # TODO: need to display game stats
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

        def update_feedback_area
          if @registered
            @feedback_area.clear do
              if @client.waiting? then
                para 'Click "Test Button"'
              else
                para 'AVAST!!'
                #@client.issue_command 'Test Button'
              end
            end
          end
        end

        def update_chat_room
          if @registered
            @chat_title.replace "Pub Chat: #{@client.teammates.join(', ')}"

            @chat_messages.clear do
              for msg, name in @client.msg_log
                para "#{name} said: #{msg}", stroke: Boot::COLORS[:light]
              end
            end
          end
        end

        def update_on_registration_change
          detect_registration_change do
            @updating_area.clear do
              if @registered
                button("Test Action") { @client.perform_action 'Test Action', Time.now, DRb.uri }
                button("Test Button") { @client.clicked 'Test Button' }
              else
                button("Register")    { register }
              end
            end

            # chat input box only appears when registered
            @chat_input.clear do
              if @registered
                el = edit_line

                button("Send") {
                  unless el.text.empty?
                    @client.broadcast(el.text)
                    el.text = ''
                  end
                }
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
