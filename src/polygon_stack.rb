require_relative "constants"
require_relative "polygon"

class PolygonStack
  def initialize(initial_points:, color:, stroke:)
    @initial_points = initial_points
    @color = color
    @stroke = stroke
  end

  def blobs
    initial_polygon = Polygon.new(points: @initial_points, color: @color, stroke: @stroke)

    initial_deformation_count = @stroke ? Constants::WATERCOLOR_SPLAT_INITIAL_DEFORMATIONS : Constants::WATERCOLOR_INITIAL_DEFORMATIONS

    initial_deformation_count.times do
      initial_polygon = initial_polygon.deform
    end

    transformed_polygons = []

    slice_count = @stroke ? Constants::WATERCOLOR_SPLAT_SLICE_COUNT : Constants::WATERCOLOR_SLICE_COUNT

    slice_count.times do |_idx|
      polygon = initial_polygon

      deformation_count = @stroke ? Constants::WATERCOLOR_SPLAT_SLICE_DEFORMATIONS : Constants::WATERCOLOR_SLICE_DEFORMATIONS

      deformation_count.times do
        polygon = polygon.deform
      end

      transformed_polygons << polygon
    end

    transformed_polygons
  end
end
