class PlantCollection
  def initialize(attributes:, image_number:)
    @attributes = attributes
    @image_number = image_number
    render
  end

  attr_reader :leaf_image

  attr_reader :shadow_image

  private

  def render
    @leaf_image = Magick::Image.new(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) { self.background_color = "white" }

    leaf_count = Util.random_leaf_count

    gaps = []
    gap_count = Util.random_leaf_gap_count

    gap_count.times do
      gap_angle = (rand * (Constants::LEAF_GAP_MAX_ANGLE - Constants::LEAF_GAP_MIN_ANGLE)) + Constants::LEAF_GAP_MIN_ANGLE
      gap_position = 360.0 * rand
      gaps << Gap.new(angle_spread: gap_angle, angle_position: gap_position)
    end

    existing_rotations = []

    global_scale = (rand * (Constants::MAX_GLOBAL_SCALE - Constants::MIN_GLOBAL_SCALE)) + Constants::MIN_GLOBAL_SCALE

    center_max_wiggle_x = Constants::IMAGE_WIDTH * 0.3
    center_max_wiggle_y = Constants::IMAGE_HEIGHT * 0.3
    center_negate_x = rand < 0.5
    center_negate_y = rand < 0.5

    wiggle_x = rand * center_max_wiggle_x * (center_negate_x ? -1.0 : 1.0)
    wiggle_y = rand * center_max_wiggle_y * (center_negate_y ? -1.0 : 1.0)

    leaf_count.round.times do
      number = (1..14).to_a.sample

      rotation = Util.next_leaf_rotation(existing_rotations: existing_rotations, gaps: gaps)
      existing_rotations << rotation

      scale = global_scale + (rand * 0.35)

      leaf = LeafImage.new(image_number: number, rotation: rotation, scale: scale)

      x_offset = (Constants::IMAGE_WIDTH / 2.0) - leaf.offsets[:x]
      y_offset = (Constants::IMAGE_HEIGHT / 2.0) - leaf.offsets[:y]

      image = leaf.rotated_image

      @leaf_image = @leaf_image.composite(
        image,
        x_offset + wiggle_x,
        y_offset + wiggle_y,
        Magick::OverCompositeOp
      )
    end

    @shadow_image = Magick::ImageList.new
    @shadow_image.new_image(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) { self.background_color = "none" }
    # # shadow_image.alpha(Magick::ActivateAlphaChannel)
    # # shadow_image.background_color = "none"
    @shadow_image.mask(@leaf_image)

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
    # shadow_image = leaf_image.copy
    # shadow_image.background_color = "none"
    # shadow_image.alpha(Magick::ActivateAlphaChannel)
    # shadow_image = shadow_image.transparent('white')
    if Constants::SAVE_COMPONENT_IMAGES
      @shadow_image.write("shadow#{@image_number}.png") { self.format = "png" }
    end
  end
end
