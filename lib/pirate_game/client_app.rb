module PirateGame
  class ClientApp

    def self.run
      @my_app = Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do

        @client = nil

        def launch_screen
          clear do
            background Boot::COLORS[:dark]
            stack margin: 20 do
              title "What's your name", stroke: Boot::COLORS[:light]
              el = edit_line text: 'Name' do |s|
                @name = s.text
              end
              button('launch') {
                @client = Client.new(name: @name)
                select_game_screen
              }
            end
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
                  button(mothership[:name]) {|b|
                    begin
                      @client.initiate_communication_with_mothership(b.text)
                      @client.register
                    rescue
                      select_game_screen
                    end
                    pub_screen
                  }
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
            animate(5) {
              if @client

                detect_registration_change

                if @registered
                  @chat_room.clear do
                    caption "In the Pub", stroke: Boot::COLORS[:light]
                    para @client.teammates.join(', '), stroke: Boot::COLORS[:light]
                    for msg, name in @client.msg_log
                      para "#{name} said: #{msg}", stroke: Boot::COLORS[:light]
                    end
                  end
                end
              end
            }
            animate(5) {
              stage_screen if @client.bridge
            }
          end
        end

        def stage_screen
          clear do
            background Boot::COLORS[:sky]
            stack :margin => 20 do
              title "Ahoy!", stroke: Boot::COLORS[:dark]

              @button_flow = flow do
                for item in @client.bridge.items
                  button(item) {|b| @client.perform_action b.text }
                end
              end
            end
            animate(5) {
              pub_screen unless @client.bridge
            }
          end
        end

        def detect_registration_change
          if @registered != @client.registered?
            @registered = @client.registered?
            @status.replace "#{"Not " unless @registered}Registered"
            @updating_area.clear do
              if @registered
                button("Test Action") { @client.perform_action 'Test Action' }

                el = edit_line

                button("Send") {
                  @client.broadcast(el.text)
                  el.text = ''
                }
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

        launch_screen
      end
    ensure
      @my_app.unregister if @my_app
    end
  end
end
