class PirateGame::MasterApp

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
          background black
          title "Start Game", stroke: white
          edit_line text: 'Name' do |s|
            @name = s.text
          end
          button('launch') {
            @game_master = PirateGame::GameMaster.new(name: @name)
            display_screen
          }
        end
      end

      def display_screen
        @game_master.update

        clear do
          background "#ffffff"

          stack :margin => 20 do
            title "Game #{@game_master.name}"

            @stuff = stack
          end
          animate(5) {
            @stuff.clear do
              if @game_master.startable?
                button ('start stage') {
                  @game_master.start
                }
              end

              para @game_master.registrations_text
              para @game_master.stage_info
            end
          }
        end
      end

      launch_screen
    end
  end
end

