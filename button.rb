class Button
    attr_accessor :x, :y, :width, :height, :label, :enabled
  
    def initialize(x, y, width, height, label)
      @x, @y, @width, @height = x, y, width, height
      @label = label
      @enabled = false
      @font = Gosu::Font.new(height, name: "Montserrat-SemiBold.ttf")  # Create a new font object with a size based on the button height
    end
  
    def draw
      Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color::BLACK, 10001)
      @font.draw_text(@label, @x+(@width/2)-(@font.text_width(@label)/2), @y, 10001)
    end
  
    def clicked?(mouse_x, mouse_y)
      mouse_x > @x && mouse_x < @x + @width && mouse_y > @y && mouse_y < @y + @height
    end
  end