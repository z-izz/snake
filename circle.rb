require 'gosu'

class Circle
  attr_accessor :x, :y
  attr_reader :radius

  def initialize(x, y, radius)
    @x, @y, @radius = x, y, radius
  end

  def collides_with?(other)
    distance = Gosu.distance(@x, @y, other.x, other.y)
    distance < (@radius + other.radius)
  end

  def draw(n, color, z = 0, mode = :default)
    angle = 2.0 * Math::PI / n
    last_x = @x + @radius
    last_y = @y
    n.times do |i|
      new_x = @x + @radius * Math.cos(angle * (i + 1))
      new_y = @y + @radius * Math.sin(angle * (i + 1))
      Gosu::draw_triangle(@x, @y, color, last_x, last_y, color, new_x, new_y, color, z, mode)
      last_x = new_x
      last_y = new_y
    end
  end
end
