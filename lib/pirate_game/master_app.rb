class PirateGame::MasterApp

  ##
  # Starts the master application.

  def self.run
    new.run
  end

  def initialize # :nodoc:
    @game_master = nil
  end

  ##
  # Creates a Shoes app for the game master and runs it.

  def run
    Shoes.app width: 360, height: 360, resizeable: false, title: 'Game Master' do

      ##
      # The launch screen asks for a game name that players can join.  When a
      # name is chosen for the game and the game launched the
      # display_screen is shown.

      def launch_screen
        clear do
          background PirateGame::Boot::COLORS[:dark]
          stack margin: 20 do
            title "Start Game", stroke: PirateGame::Boot::COLORS[:light]
            edit_line text: 'Name' do |s|
              @name = s.text
            end
            button('launch') {
              @game_master = GameMaster.new(name: @name)
              display_screen
            }
          end
        end
      end

      ##
      # The display screen shows a "start" button and the current game status.
      # The "start" button starts a new stage for the players.
      #
      # While a stage is in progress statistics will be shown on the number of
      # actions completed and who completed them.

      def display_screen
        @game_master.update

        clear do
          background PirateGame::Boot::COLORS[:light]

          stack :margin => 20 do
            title "Game #{@game_master.name}",
                  stroke: PirateGame::Boot::COLORS[:dark]

            @button_stack  = stack
            @registrations = para stroke: PirateGame::Boot::COLORS[:dark]
            @stage_info    = para stroke: PirateGame::Boot::COLORS[:dark]
            @game_info     = para stroke: PirateGame::Boot::COLORS[:dark]
          end

          animate(5) {
            detect_state_change {
              update_button_stack
            }

            detect_stage_status_change {
              @game_master.send_stage_info_to_clients
            }

            @registrations.replace @game_master.registrations_text
            @stage_info.replace @game_master.stage_info
            @game_info.replace @game_master.game_info
          }
        end
      end

      ##
      # Responsible for updating the display of the START button

      def update_button_stack
        @button_stack.clear do
          case @state
          when :startable
            button('START') {
              @game_master.start
            }
          end
        end
      end

      ##
      # If the game_master.state has changed, yields to the block.

      def detect_state_change
        return if @state == @game_master.state

        @state = @game_master.state

        yield
      end

      ##
      # If the stage status has changed, yields to the block

      def detect_stage_status_change
        return unless @game_master.stage
        return if @stage_status == @game_master.stage.status

        @stage_status = @game_master.stage.status

        yield
      end

      launch_screen
    end
  end
end

