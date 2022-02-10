class Color
  SIXTIES_COLORS = [
    { h: 336, s: 65.7, v: 80.0 },
    { h: 60, s: 16.6, v: 96.9 },
    { h: 47, s: 42.9, v: 94.1 },
    { h: 265, s: 82.6, v: 81.2 },
    { h: 354, s: 55.5, v: 86.3 },
    { h: 143, s: 54.1, v: 72.5, is_green_range: true },
    { h: 74, s: 52.7, v: 51.4, is_green_range: true }
  ]

  SEVENTIES_COLORS = [
    { h: 2, s: 78.1, v: 41.2 },
    { h: 22, s: 64.6, v: 89.8 },
    { h: 22, s: 77.1, v: 82.4 },
    { h: 10, s: 77.6, v: 71.8 },
    { h: 190, s: 46.8, v: 55.3, is_green_range: true },
    { h: 167, s: 14.4, v: 65.5, is_green_range: true }
  ]

  attr_reader :is_green_range

  def initialize(h:, s:, v:)
    @h = h
    @s = s
    @v = v
  end

  def self.random_color(green: false, palette:)
    color_options = case palette
    when :planty
      SIXTIES_COLORS
    when :sixties
      SIXTIES_COLORS
    when :seventies
      SEVENTIES_COLORS
    when :eighties
      SEVENTIES_COLORS
    when :nineties
      SEVENTIES_COLORS
    end

    if green
      color = color_options.filter { |c| c[:is_green_range] }.sample
    else
      color = color_options.reject { |c| c[:is_green_range] }.sample
    end
    self.new(h: color[:h], s: color[:s], v: color[:v]).shift
  end

  def shift
    @s = [[@s + (rand * 30.0) - 20.0, 0.0].max, 100.0].min
    @v = [[@v + (rand * 30.0) - 20.0, 0.0].max, 100.0].min
    self
  end

  def to_rgb
    h = @h.to_f / 360.0
    s = @s.to_f / 100.0
    v = @v.to_f / 100.0

    h_i = (h * 6).to_i
    f = h * 6 - h_i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)
    r, g, b = v, t, p if h_i == 0
    r, g, b = q, v, p if h_i == 1
    r, g, b = p, v, t if h_i == 2
    r, g, b = p, q, v if h_i == 3
    r, g, b = t, p, v if h_i == 4
    r, g, b = v, p, q if h_i == 5

    parts = [(r * 255).to_i, (g * 255).to_i, (b * 255).to_i]

    parts.map { |c| c.to_s(16).rjust(2, '0') }.join
  end
end
