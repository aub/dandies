require 'RMagick'
include Magick

require 'distribution'

SKIP_WATERCOLOR = false

SHADOW_OFFSET = 15

WIDTH = 2000
HEIGHT = 1300

WILDNESS_FACTOR = 30.0
WILDNESS_MIN = 40.0

SPLAT_WILDNESS_FACTOR = 0.2
SPLAT_WILDNESS_MIN = 2.0

CIRCLE_WILDNESS_FACTOR = 15.0
CIRCLE_WILDNESS_MIN = 25.0

WATERCOLOR_X_MIN = -100
WATERCOLOR_X_MAX = WIDTH + 100
WATERCOLOR_Y_MIN = -100
WATERCOLOR_Y_MAX = HEIGHT + 100
WATERCOLOR_STRIPE_COUNT = 3
WATERCOLOR_STRIPE_OVERLAP = 100

WATERCOLOR_INITIAL_DEFORMATIONS = 6
WATERCOLOR_SPLAT_INITIAL_DEFORMATIONS = 3
WATERCOLOR_SLICE_COUNT = 75
WATERCOLOR_SPLAT_SLICE_COUNT = 5
WATERCOLOR_SLICE_DEFORMATIONS = 2
WATERCOLOR_SPLAT_SLICE_DEFORMATIONS = 4
WATERCOLOR_SLICE_OPACITY = 0.08
WATERCOLOR_STROKE_OPACITY = 0.45
WATERCOLOR_STROKE_WIDTH = 1.0
WATERCOLOR_SPLAT_FILL_OPACITY = 0.12

WATERCOLOR_MIN_CIRCLES = 5
WATERCOLOR_MAX_CIRCLES = 10
WATERCOLOR_MIN_CIRCLE_RADIUS = 10
WATERCOLOR_MAX_CIRCLE_RADIUS = 50

WATERCOLOR_MIN_SPLATS = 20
WATERCOLOR_MAX_SPLATS = 40
WATERCOLOR_MIN_SPLAT_RADIUS = 10
WATERCOLOR_MAX_SPLAT_RADIUS = 20

MIN_LEAVES = 35
MAX_LEAVES = 100
LEAF_MIN_ANGLE_DISTANCE = 0.0
LEAF_GAP_MIN_ANGLE = 5.0
LEAF_GAP_MAX_ANGLE = 60.0
LEAF_MIN_GAPS = 1
LEAF_MAX_GAPS = 3

def cos_deg(degrees)
  Math.cos(0.01745329252 * degrees)
end

def sin_deg(degrees)
  Math.sin(0.01745329252 * degrees)
end

class Point
  attr_reader :x
  attr_reader :y
  attr_reader :wildness

  def initialize(x:, y:, wildness: nil)
    @x = x
    @y = y
    @wildness = wildness
  end
end

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
      yield line
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
      gc.stroke("##{@color}").stroke_width(WATERCOLOR_STROKE_WIDTH).opacity(WATERCOLOR_STROKE_OPACITY)
      gc.fill_opacity(WATERCOLOR_SPLAT_FILL_OPACITY).fill("##{@color}")
    else
      gc.fill_opacity(WATERCOLOR_SLICE_OPACITY).fill("##{@color}")
    end
    gc.polygon(*polygon_values)
  end
end

class PolygonStack
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

    slice_count.times do |idx|
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
        wildness: rand() * WILDNESS_FACTOR + WILDNESS_MIN
      ),
      Point.new(
        x: @upper_left.x + @width,
        y: @upper_left.y,
        wildness: rand() * WILDNESS_FACTOR + WILDNESS_MIN
      ),
      Point.new(
        x: @upper_left.x + @width,
        y: @upper_left.y + @height,
        wildness: rand() * WILDNESS_FACTOR + WILDNESS_MIN
      ),
      Point.new(
        x: @upper_left.x,
        y: @upper_left.y + @height,
        wildness: rand() * WILDNESS_FACTOR + WILDNESS_MIN
      ),
    ]

    PolygonStack.new(initial_points: initial_points, color: @color, stroke: false)
  end
end

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
        x: @center.x + (@radius * cos_deg(angle)),
        y: @center.y + (@radius * sin_deg(angle)),
        wildness: rand() * CIRCLE_WILDNESS_FACTOR + CIRCLE_WILDNESS_MIN
      )
    end

    PolygonStack.new(initial_points: initial_points, color: @color, stroke: false)
  end
end

class Splat
  def initialize(center:, radius:, color:)
    @center = center
    @radius = radius
    @color = color
  end

  def to_polygon_stack
    initial_points = []

    0.step(359, 30).each do |angle|
      initial_points << Point.new(
        x: @center.x + (@radius * cos_deg(angle)),
        y: @center.y + (@radius * sin_deg(angle)),
        wildness: rand() * SPLAT_WILDNESS_FACTOR + SPLAT_WILDNESS_MIN
      )
    end

    PolygonStack.new(initial_points: initial_points, color: @color, stroke: true)
  end
end

shape_blob_collections = []

unless SKIP_WATERCOLOR
  WATERCOLOR_STRIPE_COUNT.times do |idx|
    stripe_height = HEIGHT / WATERCOLOR_STRIPE_COUNT

    gos = ["4", "5", "6", "7", "8", "9", "a", "b"]
    oos = ["0", "1", "2", "3", "4"]
    color = "#{oos.sample}#{oos.sample}#{gos.sample}#{gos.sample}#{oos.sample}#{oos.sample}"

    shape = Rectangle.new(
      upper_left: Point.new(
        x: WATERCOLOR_X_MIN,
        y: (idx * stripe_height) - WATERCOLOR_STRIPE_OVERLAP
      ),
      width: WATERCOLOR_X_MAX - WATERCOLOR_X_MIN,
      height: stripe_height + (2.0 * WATERCOLOR_STRIPE_OVERLAP),
      color: color
    )

    stack = shape.to_polygon_stack
    shape_blob_collections << stack.blobs
  end

  circle_count = ((rand() * (WATERCOLOR_MAX_CIRCLES - WATERCOLOR_MIN_CIRCLES)) + WATERCOLOR_MIN_CIRCLES).round

  circle_count.times do
    x_position = rand() * WIDTH
    y_position = rand() * HEIGHT

    radius = (rand() * (WATERCOLOR_MAX_CIRCLE_RADIUS - WATERCOLOR_MIN_CIRCLE_RADIUS)) + WATERCOLOR_MIN_CIRCLE_RADIUS

    gos = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
    color = "#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}"

    shape = Circle.new(
      center: Point.new(x: x_position, y: y_position),
      radius: radius,
      color: color
    )
    stack = shape.to_polygon_stack
    shape_blob_collections << stack.blobs
  end
end

stripe_image = Magick::ImageList.new
stripe_image.new_image(WIDTH, HEIGHT) { self.background_color = "white" }

if shape_blob_collections.any?
  gc = Magick::Draw.new
  (0..(shape_blob_collections[0].count - 1)).to_a.each_slice(5) do |slice_indices|
    slice_indices.each do |idx|
      shape_blob_collections.each do |collection|
        collection[idx].render(gc: gc)
      end
    end
  end
  gc.draw(stripe_image)
end





splat_blob_collections = []

unless SKIP_WATERCOLOR
  splat_count = ((rand() * (WATERCOLOR_MAX_SPLATS - WATERCOLOR_MIN_SPLATS)) + WATERCOLOR_MIN_SPLATS).round

  gos = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a"]
  splat_color = "#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}"

  splat_count.times do
    x_position = rand() * WIDTH
    y_position = rand() * HEIGHT

    radius = (rand() * (WATERCOLOR_MAX_SPLAT_RADIUS - WATERCOLOR_MIN_SPLAT_RADIUS)) + WATERCOLOR_MIN_SPLAT_RADIUS

    shape = Splat.new(
      center: Point.new(x: x_position, y: y_position),
      radius: radius,
      color: splat_color
    )
    stack = shape.to_polygon_stack
    splat_blob_collections << stack.blobs
  end

  splat_image = Magick::ImageList.new
  splat_image.new_image(WIDTH, HEIGHT) { self.background_color = "none" }
  splat_image.alpha(Magick::ActivateAlphaChannel)
  splat_image.background_color = "none"


  if splat_blob_collections.any?
    gc = Magick::Draw.new
    (0..(splat_blob_collections[0].count - 1)).to_a.each_slice(5) do |slice_indices|
      slice_indices.each do |idx|
        splat_blob_collections.each do |collection|
          collection[idx].render(gc: gc)
        end
      end
    end
    gc.draw(splat_image)
  end

  splat_image = splat_image.blur_image(1.0, 1.0)
  splat_image.write("splats.png") { self.format = "png" }

  stripe_image = stripe_image.blur_image(5.0, 1.5)
  stripe_image = stripe_image.composite(
    splat_image,
    0,
    0,
    AtopCompositeOp
  )
  stripe_image.write("watercolor.png") { self.format = "png" }
end

















class LeafImage
  STEM_OFFSETS_BY_IMAGE_NUMBER = {
    1 => 65,
    2 => 76,
    3 => 89,
    4 => 66,
    5 => 66,
    6 => 76,
    7 => 37,
    8 => 263,
    9 => 248,
    10 => 175,
    11 => 230,
    12 => 212,
    13 => 204,
    14 => 213
  }

  attr_reader :image_number
  attr_reader :rotated_image
  attr_reader :rotation

  def initialize(image_number:, rotation:, scale:)
    @image_number = image_number
    @rotation = rotation
    @scale = scale
    @unrotated_image = ImageList.new("images/leaf#{@image_number}.png").scale(@scale)
    @unrotated_image.alpha(Magick::ActivateAlphaChannel)
    @unrotated_image.background_color = "none"
    @rotated_image = @unrotated_image.rotate(@rotation)
    @rotated_image.alpha(Magick::ActivateAlphaChannel)
    @rotated_image.background_color = "none"
  end

  def offsets
    return @offsets if defined?(@offsets)

    stem_x_from_center = -1.0 * ((@unrotated_image.columns / 2.0) - (STEM_OFFSETS_BY_IMAGE_NUMBER[@image_number] * @scale))
    stem_y_from_center = @unrotated_image.rows / 2.0

    stem_x_from_center_rotated =
      (stem_x_from_center * cos_deg(@rotation)) - (stem_y_from_center * sin_deg(@rotation))

    stem_y_from_center_rotated =
      (stem_x_from_center * sin_deg(@rotation)) + (stem_y_from_center * cos_deg(@rotation))

    rotated_center_x = @rotated_image.columns / 2.0
    rotated_center_y = @rotated_image.rows / 2.0

    rotated_stem_x = rotated_center_x + stem_x_from_center_rotated
    rotated_stem_y = rotated_center_y + stem_y_from_center_rotated

    @offsets = {
      x: rotated_stem_x,
      y: rotated_stem_y
    }
  end
end

leaf_image = Image.new(WIDTH, HEIGHT) { self.background_color = "white" }

leaf_count = (rand() * (MAX_LEAVES - MAX_LEAVES)) + MIN_LEAVES

class Gap
  attr_reader :angle_spread
  attr_reader :angle_position

  def initialize(angle_spread:, angle_position:)
    @angle_spread = angle_spread
    @angle_position = angle_position
  end
end

gaps = []
gap_count = (rand() * (LEAF_MAX_GAPS - LEAF_MIN_GAPS)).ceil + LEAF_MIN_GAPS

gap_count.times do
  gap_angle = (rand() * (LEAF_GAP_MAX_ANGLE - LEAF_GAP_MIN_ANGLE)) + LEAF_GAP_MIN_ANGLE
  gap_position = 360.0 * rand()
  gaps << Gap.new(angle_spread: gap_angle, angle_position: gap_position)
end

def next_leaf_rotation(existing_rotations:, gaps:)
  bad = true
  rotation = 0.0
  while bad do
    rotation = 360.0 * rand()
    bad = existing_rotations.any? do |r|
      (r - rotation).abs <= LEAF_MIN_ANGLE_DISTANCE
    end
    bad ||= gaps.any? do |gap|
      half = gap.angle_spread / 2.0
      (rotation > gap.angle_position - half) && (rotation < gap.angle_position + half)
    end
  end
  rotation
end

existing_rotations = []

global_scale = (rand() * 0.5) + 0.1
x_position = (rand() * WIDTH * 0.2) - (WIDTH * 0.2 * 0.5)
y_position = (rand() * HEIGHT * 0.2) + (HEIGHT * 0.2 * 0.5)

leaf_count.round.times do
  number = (1..14).to_a.sample

  rotation = next_leaf_rotation(existing_rotations: existing_rotations, gaps: gaps)
  existing_rotations << rotation
  # number = 7

  scale = global_scale + (rand() * 0.35)

  leaf = LeafImage.new(image_number: number, rotation: rotation, scale: scale)

  center_x = WIDTH / 2.0

  x_offset = center_x - leaf.offsets[:x]
  y_offset = (HEIGHT / 2.0) - leaf.offsets[:y]

  image = leaf.rotated_image

  leaf_image = leaf_image.composite(
    image,
    x_offset + x_position,
    y_offset + y_position,
    OverCompositeOp
  )
end


















# texture_image = Magick::ImageList.new
# texture_image.new_image(WIDTH, HEIGHT) { self.background_color = "none" }
# gc = Magick::Draw.new
# gc.stroke("#ff0000").stroke_width(WATERCOLOR_STROKE_WIDTH).opacity(WATERCOLOR_STROKE_OPACITY)
# gc.fill_opacity(WATERCOLOR_SPLAT_FILL_OPACITY).fill("##{@color}")
# gc.draw(texture_image)


# shadow = leaf_image.transparent("black", alpha: 0.25)
# shadow.opacity = 25.0
# shadow = leaf_image.modulate(2.0)
# shadow = leaf_image.transparent('white')
# shadow = shadow.blur_image(100.0, 5.0)
# shadow.write("shadow.png") { self.format = "png" }

shadow_image = Magick::ImageList.new
shadow_image.new_image(WIDTH, HEIGHT) { self.background_color = "none" }
# # shadow_image.alpha(Magick::ActivateAlphaChannel)
# # shadow_image.background_color = "none"
shadow_image.mask(leaf_image)

grey_image = Magick::ImageList.new
grey_image.new_image(WIDTH, HEIGHT) { self.background_color = "#111111" }

shadow_image = shadow_image.composite(
  grey_image,
  0,
  0,
  OverCompositeOp
)

shadow_image = shadow_image.copy()
# shadow_image = shadow_image.resize(WIDTH / 2, HEIGHT / 2, GaussianFilter, 1.0)
# shadow_image = shadow_image.resize(WIDTH, HEIGHT, GaussianFilter, 1.0)
# shadow_image.alpha(Magick::ActivateAlphaChannel)


shadow_image = shadow_image.modulate(6.0)
shadow_image = shadow_image.blur_image(20.0, 5.0)
# shadow_image = shadow_image.transparent('white')
# shadow_image = leaf_image.copy
# shadow_image.background_color = "none"
# shadow_image.alpha(Magick::ActivateAlphaChannel)
# shadow_image = shadow_image.transparent('white')
shadow_image.write("shadow.png") { self.format = "png" }


final_image = Image.new(WIDTH, HEIGHT) { self.background_color = "#e8dcb5" }

final_image = final_image.composite(
  shadow_image,
  SHADOW_OFFSET,
  SHADOW_OFFSET,
  OverCompositeOp
)

final_image.mask(leaf_image)
final_image = final_image.composite(
  stripe_image,
  0,
  0,
  AtopCompositeOp
)

final_image.write("output.png") { self.format = "png" }
