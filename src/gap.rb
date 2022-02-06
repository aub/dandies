class Gap
  attr_reader :angle_spread
  attr_reader :angle_position

  def initialize(angle_spread:, angle_position:)
    @angle_spread = angle_spread
    @angle_position = angle_position
  end
end
