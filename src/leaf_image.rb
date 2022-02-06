require_relative "constants"
require_relative "util"

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
  }.freeze

  attr_reader :image_number
  attr_reader :rotated_image
  attr_reader :rotation

  def initialize(image_number:, rotation:, scale:)
    @image_number = image_number
    @rotation = rotation
    @scale = scale
    @unrotated_image = Magick::ImageList.new("images/leaf#{@image_number}.png").scale(@scale)
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
      (stem_x_from_center * Util.cos_deg(@rotation)) - (stem_y_from_center * Util.sin_deg(@rotation))

    stem_y_from_center_rotated =
      (stem_x_from_center * Util.sin_deg(@rotation)) + (stem_y_from_center * Util.cos_deg(@rotation))

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
