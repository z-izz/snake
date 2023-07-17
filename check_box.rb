require 'gosu'

class Checkbox
    attr_accessor :x, :y, :width, :height, :checked, :enabled
  
    def initialize(x, y, width, height)
      @x, @y, @width, @height = x, y, width, height
      @checked = false
      @enabled = false
    end
  
    def draw
      color = @checked ? Gosu::Color::GREEN : Gosu::Color::RED
      Gosu::draw_rect(@x, @y, @width, @height, color, 10001)
    end
  
    def clicked?(mouse_x, mouse_y)
      mouse_x > @x && mouse_x < @x + @width && mouse_y > @y && mouse_y < @y + @height
    end
  
    def toggle
      @checked = !@checked
    end
  end