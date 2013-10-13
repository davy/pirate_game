class PirateGame::MasterApp

  def self.run
    new.run
  end

  def initialize
    @game_master = nil
  end

  def run
    Shoes.app width: 360, height: 360, resizeable: false, title: 'Game Master' do

      @dark_color = dimgray
      @light_color = gainsboro

      def launch_screen
        clear do
          background @dark_color
          stack margin: 20 do
            title "Start Game", stroke: @light_color
            edit_line text: 'Name' do |s|
              @name = s.text
            end
            button('launch') {
              @game_master = PirateGame::GameMaster.new(name: @name)
              display_screen
            }
          end
        end
      end

      def display_screen
        @game_master.update

        clear do
          background @light_color

          stack :margin => 20 do
            title "Game #{@game_master.name}", stroke: @dark_color

            @button_stack = stack
            @registrations = para stroke: @dark_color
            @stage_info = para stroke: @dark_color
          end
          animate(5) {
            @button_stack.clear do
              if @game_master.startable?
                button('start stage') {
                  @game_master.start
                }
              end
            end

            @registrations.replace @game_master.registrations_text
            @stage_info.replace @game_master.stage_info
          }
        end
      end

      launch_screen
    end
  end
end

