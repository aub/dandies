require_relative "point"
require_relative "polygon_stack"

class Rectangle
  def initialize(upper_left:, width:, height:, color:)
    @upper_left = upper_left
    @width = width
    @height = height
    @color = color
  end

  def to_polygon_stack
    initial_points = [
      Point.new(
        x: @upper_left.x,
        y: @upper_left.y,
        wildness: (rand * Constants::WILDNESS_FACTOR) + Constants::WILDNESS_MIN
      ),
      Point.new(
        x: @upper_left.x + @width,
        y: @upper_left.y,
        wildness: (rand * Constants::WILDNESS_FACTOR) + Constants::WILDNESS_MIN
      ),
      Point.new(
        x: @upper_left.x + @width,
        y: @upper_left.y + @height,
        wildness: (rand * Constants::WILDNESS_FACTOR) + Constants::WILDNESS_MIN
      ),
      Point.new(
        x: @upper_left.x,
        y: @upper_left.y + @height,
        wildness: (rand * Constants::WILDNESS_FACTOR) + Constants::WILDNESS_MIN
      )
    ]

    PolygonStack.new(initial_points: initial_points, color: @color, stroke: false)
  end
end
