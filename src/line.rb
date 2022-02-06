require_relative "point"

class Line
  attr_reader :point1
  attr_reader :point2
  attr_reader :wildness

  def initialize(point1:, point2:, wildness:)
    @point1 = point1
    @point2 = point2
    @wildness = wildness
  end

  def midpoint
    Point.new(
      x: (point1.x + point2.x) / 2.0,
      y: (point1.y + point2.y) / 2.0,
      wildness: @wildness
    )
  end
end
