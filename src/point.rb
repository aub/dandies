class Point
  attr_reader :x
  attr_reader :y
  attr_reader :wildness

  def initialize(x:, y:, wildness: nil)
    @x = x
    @y = y
    @wildness = wildness
  end

  def distance_from(point:)
    Math.sqrt(
      ((point.x - @x) * (point.x - @x)) +
      ((point.y - @y) * (point.y - @y))
    )
  end
end
