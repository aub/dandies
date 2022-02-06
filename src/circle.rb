require_relative "constants"
require_relative "polygon_stack"
require_relative "util"

class Circle
  def initialize(center:, radius:, color:)
    @center = center
    @radius = radius
    @color = color
  end

  def to_polygon_stack
    initial_points = []

    0.step(359, 30).each do |angle|
      initial_points << Point.new(
        x: @center.x + (@radius * Util.cos_deg(angle)),
        y: @center.y + (@radius * Util.sin_deg(angle)),
        wildness: (rand * Constants::CIRCLE_WILDNESS_FACTOR) + Constants::CIRCLE_WILDNESS_MIN
      )
    end

    PolygonStack.new(initial_points: initial_points, color: @color, stroke: false)
  end
end
