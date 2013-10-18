class PirateGame::Background

  STATES = [:clear, :foggy]

  def initialize shoes, state=nil
    @shoes = shoes
    set_state state
  end

  def set_state state
    @state = state if STATES.include?(state)
    @state ||= :clear
  end

  def randomize_state
    case rand
    when 0.0..0.1
      @state = :foggy
    else
      @state = :clear
    end
  end

  def color
    case @state
    when :foggy
      @shoes.rgb(105, 138, 150, 180)
    else # :clear
      PirateGame::Boot::SKY_COLOR
    end
  end

  def draw
    @shoes.background color
  end

  def foreground?
    @state == :foggy
  end
end
