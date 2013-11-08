class PirateGame::ClientApp

  def self.run
    @my_app = Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do

      require 'pirate_game/shoes4_patch'

      def animate fps, &block
        opts = { framerate: fps }
        PirateGame::Animation.new @app, opts, block
      end

      ##
      # Creates the animation trigger for animating items.  An animatable item
      # must respond to #animate and accept a frame number.

      def animate_items
        @items_animation = animate(30) do |frame|
          @background.animate frame
        end
      end

      ##
      # Creates the waves and ship graphics that must be animated.

      def create_items
        @background = PirateGame::Background.new(self)
      end

      ##
      # Clears the app, draws the background, ship and waves, then yields to
      # draw UI items.

      def draw_items
        clear

        @background.draw do
          yield
        end
      end

      ##
      # Sets the application state

      def state= state
        @client.state = @state = state
      end

      ##
      # The launch screen.

      def launch_screen
        @items_animation.start if @items_animation

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

      ##
      # Draws a pirate ship background with waves yields to draw additional
      # UI.

      def pirate_ship
        draw_items do
          stack margin: 20 do
            yield
          end
        end
      end

      ##
      # Watches the state of the client to switch to a new screen.

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

      ##
      # Displays the UI for choosing a game to join

      def select_game_screen
        @items_animation.start if @items_animation

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
      rescue DRb::DRbConnError
        @client.state = @state = :select_game

        select_game_screen
      end

      ##
      # The pirate pub screen where you wait to start a game

      def pub_screen
        @stage_animation.remove if @stage_animation
        @items_animation.stop if @items_animation

        @pub_tagline ||= "Welcome #{@client.name}"

        clear do
          background PirateGame::Boot::COLORS[:pub]
          stack :margin => 20 do
            title "Pirate Pub", stroke: PirateGame::Boot::COLORS[:light]
            tagline @pub_tagline, stroke: PirateGame::Boot::COLORS[:light]

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
      rescue DRb::DRbConnError
        @client.state = @state = :select_game

        select_game_screen
      end

      ##
      # The screen where the game occurs

      def stage_screen
        @pub_animation.remove if @pub_animation
        @items_animation.start if @items_animation

        # if we get back to pub then stage was success
        @pub_tagline = 'SUCCESS!'

        pirate_ship do
          title PirateCommand.exclaim!, stroke: PirateGame::Boot::COLORS[:dark]

          @instruction = caption stroke: PirateGame::Boot::COLORS[:dark]
          @progress = progress

          @client.bridge.items.each_slice(3).with_index do |items, row|
            items.each_with_index do |item, column|
              bridge_button =
                PirateGame::BridgeButton.new self, item, row, column do
                  @client.clicked item
                end

              @background.add_extra_item bridge_button
            end
          end
        end

        @stage_animation = animate(10) {
          @client.issue_command unless @client.waiting?

          @instruction.replace @client.current_action

          progress_fraction = (@client.action_time_left.to_f / @client.completion_time.to_f)
          @progress.fraction = progress_fraction
        }
      rescue DRb::DRbConnError
        @client.state = @state = :select_game

        select_game_screen
      end

      ##
      # The end-game screen

      def end_screen
        @pub_animation.remove if @pub_animation
        @stage_animation.remove if @stage_animation
        @items_animation.stop if @items_animation

        clear do
          jolly_roger = File.expand_path '../../../imgs/jolly_roger_sm.png', __FILE__
          background PirateGame::Boot::COLORS[:dark]
          background jolly_roger, height: 256
          background rgb(0, 0, 0, 180)

          stack margin: 20 do

            title "END OF GAME", stroke: PirateGame::Boot::COLORS[:light]

            if @client.slop_bucket[:end_game]
              game_stats = @client.slop_bucket[:end_game]
              para "Game Stats", stroke: PirateGame::Boot::COLORS[:light]
              para "Total Stages Completed: #{game_stats[:total_stages]}", stroke: PirateGame::Boot::COLORS[:light]
              para "Total Actions: #{game_stats[:total_actions]}", stroke: PirateGame::Boot::COLORS[:light]
              para "My Contribution: #{game_stats[:player_breakdown][DRb.uri]}", stroke: PirateGame::Boot::COLORS[:light]
            end
          end
        end
      rescue DRb::DRbConnError
        @client.state = @state = :select_game

        select_game_screen
      end

      ##
      # If the registration state has changed, yields to the block.

      def detect_registration_change
        return if @client.registered? == @registered

        @registered = @client.registered?

        @status.replace "#{"Not " unless @registered}Registered"

        yield
      end

      ##
      # Updates the chat messages with new messages

      def update_chat_room
        if @registered
          @chat_messages.clear do
            for msg, name in @client.log_book
              para "#{name} said: #{msg}", stroke: PirateGame::Boot::COLORS[:light]
            end
          end
        end
      end

      ##
      # Updates the registration view in the pub screen

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

      ##
      # Draws a button for joining a game playing on +mothership+

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

      ##
      # Registers the client with a game master

      def register
        @client.register if @client
      end

      ##
      # Unregisters a game with a game master

      def unregister
        @client.unregister if @client
      end

      @client = nil
      create_items
      animate_items
      launch_screen
    end
  ensure
    @my_app.unregister if @my_app
  end

end

