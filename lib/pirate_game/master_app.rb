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
            end
            animate(5) {
              detect_startable_change

              @registrations.replace @game_master.registrations_text
              @stage_info.replace @game_master.stage_info
            }
          end
        end

        def detect_startable_change
          if @startable != @game_master.startable?
            @startable = @game_master.startable?

            @button_stack.clear do
              if @startable
                button('start stage') {
                  @game_master.start
                }
              end
            end
          end
        end

        launch_screen
      end
    end
  end
end
