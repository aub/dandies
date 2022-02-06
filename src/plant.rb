class Plant
  def initialize(leaf_image:, position:, global_scale:)
    @leaf_image = leaf_image
    @position = position
    @global_scale = global_scale
  end
  
  def render(plant_count:)
    leaf_count = Util.random_leaf_count

    gaps = []
    gap_count = Util.random_leaf_gap_count

    gap_count.times do
      gap_angle = (rand * (Constants::LEAF_GAP_MAX_ANGLE - Constants::LEAF_GAP_MIN_ANGLE)) + Constants::LEAF_GAP_MIN_ANGLE
      gap_position = 360.0 * rand
      gaps << Gap.new(angle_spread: gap_angle, angle_position: gap_position)
    end

    existing_rotations = []

    global_scale = Util.random_global_scale(plant_count: plant_count)

    center_max_x = Constants::IMAGE_WIDTH * 0.3
    center_max_y = Constants::IMAGE_HEIGHT * 0.3
    center_negate_x = rand < 0.5
    center_negate_y = rand < 0.5

    center_x = rand * center_max_x * (center_negate_x ? -1.0 : 1.0)
    center_y = rand * center_max_y * (center_negate_y ? -1.0 : 1.0)

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
        x_offset + center_x,
        y_offset + center_y,
        Magick::OverCompositeOp
      )
    end
  end
end
