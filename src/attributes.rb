class Attributes
  def initialize
    plant_count_random = rand
    plant_count = 1
    plant_count = 2 if plant_count_random > 0.5
    plant_count = 3 if plant_count_random > 0.75
    plant_count = 4 if plant_count_random > 0.875
    plant_count = 5 if plant_count_random > 0.95
    plant_count = 6 if plant_count_random > 0.98

    # palette_random = rand
    # palette = :planty
    # palette = :sixties if palette_random > 0.5
    # palette = :doom if palette_random > 0.75
    # palette = :eighties if palette_random > 0.875
    # palette = :nineties if palette_random > 0.95
    palette = [:planty, :sixties, :doom].sample

    splat_splash_random = rand

    @attributes = {
      palette: palette,
      plant_count: plant_count,
      splashes: true, # splat_splash_random >= 0.95,
      splats: true # splat_splash_random >= 0.75
    }
  end

  def palette
    @attributes[:palette]
  end

  def plant_count
    @attributes[:plant_count]
  end

  def splats?
    @attributes[:splats]
  end

  def splashes?
    @attributes[:splashes]
  end
end
