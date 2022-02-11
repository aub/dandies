require_relative "constants"

class Util
  WATERCOLOR_MIN_CIRCLES = 10
  WATERCOLOR_MAX_CIRCLES = 20
  WATERCOLOR_MIN_CIRCLE_RADIUS = 50
  WATERCOLOR_MAX_CIRCLE_RADIUS = 80
  WATERCOLOR_MIN_SPLATS = 30
  WATERCOLOR_MAX_SPLATS = 60
  WATERCOLOR_MIN_SPLAT_RADIUS = 10
  WATERCOLOR_MAX_SPLAT_RADIUS = 20
  MIN_LEAVES = 25
  MAX_LEAVES = 45
  LEAF_MIN_ANGLE_DISTANCE = 0.0
  LEAF_MIN_GAPS = 1
  LEAF_MAX_GAPS = 3

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
        (r - rotation).abs <= LEAF_MIN_ANGLE_DISTANCE
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
    random_in_range(min: WATERCOLOR_MIN_CIRCLE_RADIUS, max: WATERCOLOR_MAX_CIRCLE_RADIUS)
  end

  def self.random_watercolor_splat_radius
    random_in_range(min: WATERCOLOR_MIN_SPLAT_RADIUS, max: WATERCOLOR_MAX_SPLAT_RADIUS)
  end

  def self.random_watercolor_splat_count
    random_in_range(min: WATERCOLOR_MIN_SPLATS, max: WATERCOLOR_MAX_SPLATS).round
  end

  def self.random_watercolor_circle_count
    random_in_range(min: WATERCOLOR_MIN_CIRCLES, max: WATERCOLOR_MAX_CIRCLES).round
  end

  def self.random_leaf_count
    random_in_range(min: MIN_LEAVES, max: MAX_LEAVES).round
  end

  def self.random_leaf_gap_count
    random_in_range(min: LEAF_MIN_GAPS, max: LEAF_MAX_GAPS).round
  end

  def self.random_global_scale(plant_count:)
    numerator = case plant_count
    when 1
      1.0
    when 2
      2.0
    when 3
      6.0
    when 4
      10.0
    when 5
      15.0
    when 6
      25.0
    end
    random_in_range(min: Constants::MIN_GLOBAL_SCALE, max: Constants::MAX_GLOBAL_SCALE) / numerator
  end
end
