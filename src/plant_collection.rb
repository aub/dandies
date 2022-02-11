require_relative 'point'

class PlantCollection
  LEAF_GAP_MIN_ANGLE = 5.0
  LEAF_GAP_MAX_ANGLE = 60.0
  CENTER_MAX_X = (Constants::IMAGE_WIDTH - 200.0) / 2.0
  CENTER_MAX_Y = (Constants::IMAGE_HEIGHT - 200.0) / 2.0
  MIN_PLANT_DISTANCE = 250.0

  def initialize(attributes:, image_number:)
    @attributes = attributes
    @image_number = image_number
    render
  end

  attr_reader :plants_image
  attr_reader :shadow_image

  private

  def random_plant_position
    center_negate_x = rand < 0.5
    center_negate_y = rand < 0.5

    Point.new(
      x: rand * CENTER_MAX_X * (center_negate_x ? -1.0 : 1.0),
      y: rand * CENTER_MAX_Y * (center_negate_y ? -1.0 : 1.0)
    )
  end

  def next_plant_position(previous_positions:)
    if previous_positions && previous_positions.any?
      min_distance = 0
      position = nil
      while min_distance < MIN_PLANT_DISTANCE
        position = random_plant_position

        distances = previous_positions.map { |pos| pos.distance_from(point: position) }
        min_distance = distances.min
      end

      position
    else
      random_plant_position
    end
  end

  def render
    @plants_image = Magick::Image.new(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) { self.background_color = "white" }

    plant_count = @attributes.plant_count
    plant_positions = []

    plant_count.times do
      global_scale = Util.random_global_scale(plant_count: plant_count)
      position = next_plant_position(previous_positions: plant_positions)
      puts "PLANT AT #{position.x} -> #{position.y}"
      plant_positions << position

      @plants_image = render_plant(center: position, global_scale: global_scale, image: @plants_image)
    end

    @shadow_image = Magick::ImageList.new
    @shadow_image.new_image(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) { self.background_color = "none" }
    # # shadow_image.alpha(Magick::ActivateAlphaChannel)
    # # shadow_image.background_color = "none"
    @shadow_image.mask(@plants_image)

    grey_image = Magick::ImageList.new
    grey_image.new_image(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) { self.background_color = "#111111" }

    @shadow_image = shadow_image.composite(
      grey_image,
      0,
      0,
      Magick::OverCompositeOp
    )

    @shadow_image = shadow_image.copy
    # shadow_image = shadow_image.resize(WIDTH / 2, HEIGHT / 2, GaussianFilter, 1.0)
    # shadow_image = shadow_image.resize(WIDTH, HEIGHT, GaussianFilter, 1.0)
    # shadow_image.alpha(Magick::ActivateAlphaChannel)

    @shadow_image = shadow_image.modulate(6.0)
    @shadow_image = shadow_image.blur_image(20.0, 5.0)
    # shadow_image = shadow_image.transparent('white')
    # shadow_image = @plants_image.copy
    # shadow_image.background_color = "none"
    # shadow_image.alpha(Magick::ActivateAlphaChannel)
    # shadow_image = shadow_image.transparent('white')
    if Constants::SAVE_COMPONENT_IMAGES
      @shadow_image.write("shadow#{@image_number}.png") { self.format = "png" }
    end
  end

  def render_plant(center:, global_scale:, image:)
    leaf_count = Util.random_leaf_count

    gaps = []
    gap_count = Util.random_leaf_gap_count

    gap_count.times do
      gap_angle = (rand * (LEAF_GAP_MAX_ANGLE - LEAF_GAP_MIN_ANGLE)) + LEAF_GAP_MIN_ANGLE
      gap_position = 360.0 * rand
      gaps << Gap.new(angle_spread: gap_angle, angle_position: gap_position)
    end

    existing_rotations = []

    leaf_count.round.times do
      number = (1..14).to_a.sample

      rotation = Util.next_leaf_rotation(existing_rotations: existing_rotations, gaps: gaps)
      existing_rotations << rotation

      scale = global_scale + (rand * 0.35)

      leaf = LeafImage.new(image_number: number, rotation: rotation, scale: scale)

      x_offset = (Constants::IMAGE_WIDTH / 2.0) - leaf.offsets[:x]
      y_offset = (Constants::IMAGE_HEIGHT / 2.0) - leaf.offsets[:y]

      leaf_image = leaf.rotated_image

      image = image.composite(
        leaf_image,
        x_offset + center.x,
        y_offset + center.y,
        Magick::OverCompositeOp
      )
    end

    image
  end
end
