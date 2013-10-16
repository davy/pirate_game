class PirateGame::ClientApp

  def self.run
    @my_app = Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do

      require 'pirate_game/shoes4_patch'

      @client = nil

      def animate_items items
        animate(30) do |frame|
          items.each do |item|
            item.animate frame
          end
        end
      end

      def background_items
        items = []

        items << PirateGame::Wave.new(self, 0, 30)

        image = File.expand_path '../../../imgs/pirate_ship_sm.png', __FILE__

        items << PirateGame::Image.new(self, image, 66, 55)

        [[20, 7], [40, 42], [60, -3], [80, 22]].each do |top, seed|
          items << PirateGame::Wave.new(self, top, seed)
        end

        items
      end

      def draw items
        clear

        background PirateGame::Boot::COLORS[:sky]

        items.each do |item|
          item.draw
        end

        yield
      end

      def launch_screen
        pirate_ship do
          title "What's your name", stroke: PirateGame::Boot::COLORS[:dark]

          edit_line text: 'Name' do |s|
            @name = s.text
          end

          button('launch') {
            @client = PirateGame::Client.new(name: @name)
          }
        end

        @state_watcher = animate(5) {
          watch_state
        }
      end

      def pirate_ship
        items = background_items

        draw items do
          stack margin: 20 do
            yield
          end
        end

        animate_items items
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
        motherships = @client.find_all_motherships

        title_text = if motherships.empty? then
                       "No Games Found"
                     else
                       "Choose Game"
                     end

        pirate_ship do
          title title_text, stroke: PirateGame::Boot::COLORS[:dark]

          for mothership in motherships
            draw_mothership_button mothership
          end

          button('rescan') {
            select_game_screen
          }
        end
      end

      def pub_screen
        @stage_animation.remove if @stage_animation

        clear do
          background PirateGame::Boot::COLORS[:pub]
          stack :margin => 20 do
            title "Pirate Pub", stroke: PirateGame::Boot::COLORS[:light]
            tagline "Welcome #{@client.name}", stroke: PirateGame::Boot::COLORS[:light]

            stack do @status = para '', stroke: PirateGame::Boot::COLORS[:light] end

            @registered = nil
            @updating_area = stack
            stack do
              @chat_title = tagline 'Pub Chat', stroke: PirateGame::Boot::COLORS[:light]
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
              update_chat_room
            end
          }
        end
      end

      def stage_screen
        @pub_animation.remove if @pub_animation

        pirate_ship do
          title PirateCommand.exclaim!, stroke: PirateGame::Boot::COLORS[:dark]

          @instruction = flow margin: 20

          flow do
            for item in @client.bridge.items
              button(item) {|b| @client.clicked b.text }
            end
          end
        end

        @stage_animation = animate(1) {
          @client.issue_command unless @client.waiting?

          @instruction.clear do
            para @client.action_time_left.to_i, stroke: PirateGame::Boot::COLORS[:dark]
            para @client.current_action, stroke: PirateGame::Boot::COLORS[:dark]
          end
        }
      end

      def end_screen
        @pub_animation.remove if @pub_animation
        @stage_animation.remove if @stage_animation

        clear do
          background PirateGame::Boot::COLORS[:dark]
          stack margin: 20 do
            title "END OF GAME", stroke: PirateGame::Boot::COLORS[:light]

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

      def update_chat_room
        if @registered
          @chat_title.replace "Pub Chat: #{@client.teammates.join(', ')}"

          @chat_messages.clear do
            for msg, name in @client.msg_log
              para "#{name} said: #{msg}", stroke: PirateGame::Boot::COLORS[:light]
            end
          end
        end
      end

      def update_on_registration_change
        detect_registration_change do
          @updating_area.clear do
            button("Register") { register } unless @registered
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

