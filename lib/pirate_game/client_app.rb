require 'pirate_game'

class PirateGame::ClientApp

  def self.run
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
            @client = PirateGame::Client.new(name: @name)
            select_game_screen
          }
        end
      end

      def select_game_screen
        clear do
          background black
          title "Choose Game", stroke: white

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

      def pub_screen
        clear do
          stack :margin => 20 do
            title "Pirate Pub"
            tagline "Welcome #{@client.name}"

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
                  caption "In the Pub"
                  para @client.teammates.join(', ')
                  for msg, name in @client.msg_log
                    para "#{name} said: #{msg}"
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
          stack :margin => 20 do
            title "Ahoy!"

            for item in @client.bridge.items
              button(item) {|b| @client.perform_action b.text }
            end
          end
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
