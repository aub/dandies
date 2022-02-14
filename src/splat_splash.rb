require_relative "constants"
require_relative "polygon_stack"
require_relative "util"

class SplatSplash
  SPLAT_SPLASH_WILDNESS_FACTOR = 0.2
  SPLAT_SPLASH_WILDNESS_MIN = 0.5

  def initialize(center:, color:)
    @center = center
    @color = color
  end

  def to_polygon_stack
    width = (rand * 10.0) + 0.2
    height = (rand * 10.0) + 0.2

    initial_points = Ellipse.new(
      width: width,
      height: height,
      center: @center,
      angle: Util.random_angle,
      min_wildness: SPLAT_SPLASH_WILDNESS_MIN,
      wildness_factor: SPLAT_SPLASH_WILDNESS_FACTOR
    ).points
    
    PolygonStack.new(initial_points: initial_points, color: @color, stroke: true)
  end
end
