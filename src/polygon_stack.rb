require_relative "constants"
require_relative "polygon"

class PolygonStack
  WATERCOLOR_INITIAL_DEFORMATIONS = 6
  WATERCOLOR_SPLAT_INITIAL_DEFORMATIONS = 3
  WATERCOLOR_SLICE_COUNT = 75
  WATERCOLOR_SPLAT_SLICE_COUNT = 5
  WATERCOLOR_SLICE_DEFORMATIONS = 2
  WATERCOLOR_SPLAT_SLICE_DEFORMATIONS = 4

  def initialize(initial_points:, color:, stroke:)
    @initial_points = initial_points
    @color = color
    @stroke = stroke
  end

  def blobs
    initial_polygon = Polygon.new(points: @initial_points, color: @color, stroke: @stroke)

    initial_deformation_count = @stroke ? WATERCOLOR_SPLAT_INITIAL_DEFORMATIONS : WATERCOLOR_INITIAL_DEFORMATIONS

    initial_deformation_count.times do
      initial_polygon = initial_polygon.deform
    end

    transformed_polygons = []

    slice_count = @stroke ? WATERCOLOR_SPLAT_SLICE_COUNT : WATERCOLOR_SLICE_COUNT

    slice_count.times do |_idx|
      polygon = initial_polygon

      deformation_count = @stroke ? WATERCOLOR_SPLAT_SLICE_DEFORMATIONS : WATERCOLOR_SLICE_DEFORMATIONS

      deformation_count.times do
        polygon = polygon.deform
      end

      transformed_polygons << polygon
    end

    transformed_polygons
  end
end
