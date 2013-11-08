module PirateGame
  class MasterApp

    def self.run
      new.run
    end

    def initialize
      @game_master = nil
    end

    def run
      Shoes.app width: 360, height: 360, resizeable: false, title: 'Game Master' do

        def launch_screen
          clear do
            background Boot::COLORS[:dark]
            stack margin: 20 do
              title "Start Game", stroke: Boot::COLORS[:light]
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

        def display_screen
          @game_master.update

          clear do
            background Boot::COLORS[:light]

            stack :margin => 20 do
              title "Game #{@game_master.name}", stroke: Boot::COLORS[:dark]

              @button_stack = stack
              @registrations = para stroke: Boot::COLORS[:dark]
              @stage_info = para stroke: Boot::COLORS[:dark]
              @game_info = para stroke: Boot::COLORS[:dark]
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
end
