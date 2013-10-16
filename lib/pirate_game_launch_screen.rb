require 'pirate_game'
require 'pirate_game/image'
require 'pirate_game/wave'

module PirateGame

  Shoes.app width: 360, height: 360, resizeable: false, title: 'Pirate Game' do
    def make_items
      items = []

      items << Wave.new(self, 0, 30)

      image = File.expand_path '../../imgs/pirate_ship_sm.png', __FILE__

      items << Image.new(self, image, 66, 55)

      [[20, 7], [40, 42], [60, -3], [80, 22]].each do |top, seed|
        items << Wave.new(self, top, seed)
      end

      items
    end

    def draw items
      clear

      background Boot::COLORS[:sky]

      stack margin: 20 do
        title "Pirate Game!"
      end

      items.each do |item|
        item.draw
      end
    end

    def launch_screen
      items = make_items

      draw items

      animate(30) do |frame|
        items.each do |item|
          item.animate frame
        end
      end
    end

    launch_screen
  end
end
