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
