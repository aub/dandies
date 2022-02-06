require "distribution"

require_relative "line"
require_relative "constants"
require_relative "point"

class Polygon
  attr_reader :color
  attr_reader :points
  attr_reader :stroke

  def initialize(points:, color:, stroke:)
    @points = points
    @color = color
    @stroke = stroke
  end

  def each_line
    points.each_with_index do |first_point, index|
      next_index = index + 1
      if next_index >= points.count
        next_index = 0
      end

      line = Line.new(point1: first_point, point2: @points[next_index], wildness: first_point.wildness)
      yield(line)
    end
  end

  def deform
    rng = Distribution::Normal.rng(0.1)

    new_points = []

    each_line do |line|
      new_points << line.point1

      midpoint = line.midpoint
      moved = Point.new(
        x: midpoint.x + (rng.call * midpoint.wildness),
        y: midpoint.y + (rng.call * midpoint.wildness),
        wildness: midpoint.wildness * 0.5
      )
      new_points << moved

      # new_points << line.point2
    end

    Polygon.new(points: new_points, color: @color, stroke: @stroke)
  end

  def render(gc:)
    polygon_values = []

    points.each do |point|
      polygon_values << point.x
      polygon_values << point.y

      # if @stroke
      #   gc.opacity(WATERCOLOR_STROKE_OPACITY)
      #   gc.stroke("#{@color}").stroke_width(1)
      # end
      # gc.circle(point.x, point.y, point.x + 2, point.y + 2)
    end

    # gc.opacity(WATERCOLOR_SLICE_OPACITY)
    if @stroke
      gc.stroke("##{@color}").stroke_width(Constants::WATERCOLOR_STROKE_WIDTH).opacity(Constants::WATERCOLOR_STROKE_OPACITY)
      gc.fill_opacity(Constants::WATERCOLOR_SPLAT_FILL_OPACITY).fill("##{@color}")
    else
      gc.fill_opacity(Constants::WATERCOLOR_SLICE_OPACITY).fill("##{@color}")
    end
    gc.polygon(*polygon_values)
  end
end
