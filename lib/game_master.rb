require 'shuttlecraft/mothership'

class GameMaster < Shuttlecraft::Mothership

  VERSION = '0.0.1'
  attr_accessor :stage

  def initialize

  end

end

Shoes.app width: 360, height: 360, resizeable: false, title: 'Game Master' do
  @game_master = nil

  def launch_screen
    clear do
      background black
      title "Start Game", stroke: white
      edit_line text: 'Name' do |s|
        @name = s.text
      end
      button('launch') {
        @game_master = GameMaster.new(@name)
        display_screen
      }
    end
  end

  def display_screen
    clear do
      background "#ffffff"

      stack :margin => 20 do
        title "Game #{@game_master.name}"

        stack do
          para 'Registered Services:'
          @registrations = para
        end
      end
      animate(5) { @registrations.replace registrations_text }
    end
  end

  def registrations_text
    @game_master.registered_services.join(', ') if @game_master
  end

  launch_screen
end

require 'stage'
