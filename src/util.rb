require_relative "constants"

class Util
  def self.cos_deg(degrees)
    Math.cos(0.01745329252 * degrees)
  end

  def self.sin_deg(degrees)
    Math.sin(0.01745329252 * degrees)
  end

  def self.next_leaf_rotation(existing_rotations:, gaps:)
    bad = true
    rotation = 0.0
    while bad
      rotation = 360.0 * rand
      bad = existing_rotations.any? do |r|
        (r - rotation).abs <= Constants::LEAF_MIN_ANGLE_DISTANCE
      end
      bad ||= gaps.any? do |gap|
        half = gap.angle_spread / 2.0
        (rotation > gap.angle_position - half) && (rotation < gap.angle_position + half)
      end
    end
    rotation
  end

  def self.random_in_range(min:, max:)
    (rand * (max - min)) + min
  end

  def self.random_watercolor_circle_radius
    random_in_range(min: Constants::WATERCOLOR_MIN_CIRCLE_RADIUS, max: Constants::WATERCOLOR_MAX_CIRCLE_RADIUS)
  end

  def self.random_watercolor_splat_radius
    random_in_range(min: Constants::WATERCOLOR_MIN_SPLAT_RADIUS, max: Constants::WATERCOLOR_MAX_SPLAT_RADIUS)
  end

  def self.random_watercolor_splat_count
    random_in_range(min: Constants::WATERCOLOR_MIN_SPLATS, max: Constants::WATERCOLOR_MAX_SPLATS).round
  end

  def self.random_watercolor_circle_count
    random_in_range(min: Constants::WATERCOLOR_MIN_CIRCLES, max: Constants::WATERCOLOR_MAX_CIRCLES).round
  end

  def self.random_leaf_count
    random_in_range(min: Constants::MIN_LEAVES, max: Constants::MAX_LEAVES).round
  end

  def self.random_leaf_gap_count
    random_in_range(min: Constants::LEAF_MIN_GAPS, max: Constants::LEAF_MAX_GAPS).round
  end

  def self.random_global_scale(plant_count:)
    random_in_range(min: Constants::MIN_GLOBAL_SCALE, max: Constants::MAX_GLOBAL_SCALE) / plant_count.to_f
  end
end
