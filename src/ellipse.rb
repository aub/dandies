class Ellipse

  def initialize(
    width:,
    height:,
    center:,
    angle:,
    min_wildness:,
    wildness_factor:
  )
    @width = width
    @height = height
    @center = center
    @angle = angle
    @min_wildness = min_wildness
    @wildness_factor = wildness_factor
  end

  def points
    # half_width = @radius * Util.random_in_range(max: 2.0, min: 0.6)
    # half_height = @radius * Util.random_in_range(max: 2.0, min: 0.6)

    half_width = @width / 2.0
    half_height = @height / 2.0
    
    curves = [
      Bezier::Curve.new(
        [half_width, 0.0],
        [half_width, half_height],
        [0.0, half_height]
      ),
      Bezier::Curve.new(
        [0.0, half_height],
        [-half_width, half_height],
        [-half_width, 0.0]
      ),
      Bezier::Curve.new(
        [-half_width, 0.0],
        [-half_width, -half_height],
        [0.0, -half_height]
      ),
      Bezier::Curve.new(
        [0.0, -half_height],
        [half_width, -half_height],
        [half_width, 0.0]
      )
    ]

    points = []
    curves.each do |curve|
      0.step(1.0, 0.2).each do |pct|
        pt = curve.point_on_curve(pct).to_a
        rotated_pt = [
          pt[0] * Util.cos_deg(@angle) - pt[1] * Util.sin_deg(@angle),
          pt[0] * Util.sin_deg(@angle) + pt[1] * Util.cos_deg(@angle)
        ]

        points << Point.new(
          x: @center.x + rotated_pt[0],
          y: @center.y + rotated_pt[1],
          wildness: (rand * @wildness_factor) + @min_wildness
        )
      end
    end

    points
  end
end
