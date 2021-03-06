require_relative "bezier_curve"
require_relative "constants"
require_relative "ellipse"
require_relative "polygon_stack"
require_relative "util"

class Splat
  SPLAT_WILDNESS_FACTOR = 0.2
  SPLAT_WILDNESS_MIN = 4.0

  def initialize(center:, color:)
    @center = center
    @color = color
  end

  def to_polygon_stack
    width = Util.random_watercolor_splat_radius * 2.0
    height = Util.random_watercolor_splat_radius * 2.0

    initial_points = Ellipse.new(
      width: width,
      height: height,
      center: @center,
      angle: Util.random_angle,
      min_wildness: SPLAT_WILDNESS_MIN,
      wildness_factor: SPLAT_WILDNESS_FACTOR
    ).points
    
    PolygonStack.new(initial_points: initial_points, color: @color, stroke: true)
  end
end
