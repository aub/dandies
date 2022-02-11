class Color
  PLANTY_COLORS = [
    [88, 47, 14, nil],
    [127, 79, 36, nil],
    [147, 102, 57, nil],
    [166, 138, 100, nil],
    [182, 173, 144, :background],
    [194, 197, 170, :background],
    [164, 172, 134, :background],
    [101, 109, 74, :green],
    [65, 72, 51, :green],
    [51, 61, 41, :green]
  ]

  SIXTIES_COLORS = [
    [204, 69, 123, nil],
    [228, 170, 121, nil],
    [220, 117, 73, nil],
    [201, 73, 50, nil],
    [19, 42, 81, nil],
    [96, 30, 29, nil],
    [53, 109, 136, :green],
    [75, 137, 150, :green],
    [143, 172, 165, :green],
    [136, 114, 39, :green],
    [243, 224, 186, :background],
  ]

  DOOM_COLORS = [
    [0, 100, 102, :green],
    [6, 90, 96, :green],
    [11, 82, 91, :green],
    [20, 69, 82, :green],
    [27, 58, 75, :green],
    [33, 47, 69, nil],
    [39, 38, 64, nil],
    [49, 34, 68, nil],
    [62, 31, 71, nil],
    [191, 172, 200, :background],
  ]

  SEVENTIES_COLORS = [
    { h: 2, s: 78.1, v: 41.2 },
    { h: 22, s: 64.6, v: 89.8 },
    { h: 22, s: 77.1, v: 82.4 },
    { h: 10, s: 77.6, v: 71.8 },
    { h: 190, s: 46.8, v: 55.3, is_green_range: true },
    { h: 167, s: 14.4, v: 65.5, is_green_range: true },
    { h: 46, s: 22.0, v: 91.0, is_background: true }
  ]

  def initialize(h:, s:, v:)
    @h = h
    @s = s
    @v = v
  end

  def self.random_color(green: false, background: false, palette:)
    # color_options = case palette
    # when :planty
    #   SIXTIES_COLORS
    # when :sixties
    #   SIXTIES_COLORS
    # when :seventies
    #   SIXTIES_COLORS
    # when :eighties
    #   SIXTIES_COLORS
    # when :nineties
    #   SIXTIES_COLORS
    # end
    color_options = DOOM_COLORS

    if green
      color = color_options.filter { |c| c[3] == :green }.sample
    elsif background
      color = color_options.filter { |c| c[3] == :background }.sample
    else
      color = color_options.filter { |c| c[3].nil? }.sample
    end
    hsv = rgb_to_hsv(r: color[0], g: color[1], b: color[2])
    self.new(h: hsv[:h], s: hsv[:s], v: hsv[:v]).shift(bright: background)
  end

  def shift(bright: false)
    @s = [[@s + (rand * 30.0) - 20.0, 0.0].max, 100.0].min
    if bright
      @v = (rand * 10.0) + 65.0
    else
      @v = (rand * 40.0) + 30.0
    end
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

  def self.rgb_to_hsv(r:, g:, b:)
    r = r / 255.0
    g = g / 255.0
    b = b / 255.0
    max = [r, g, b].max
    min = [r, g, b].min
    delta = max - min
    v = max * 100
  
    if (max != 0.0)
      s = delta / max * 100
    else
      s = 0.0
    end
  
    if (s == 0.0)
      h = 0.0
    else
      if (r == max)
        h = (g - b) / delta
      elsif (g == max)
        h = 2 + (b - r) / delta
      elsif (b == max)
        h = 4 + (r - g) / delta
      end
  
      h *= 60.0
  
      if (h < 0)
        h += 360.0
      end
    end
  
    { h: h, s: s, v: v }
  end
end
