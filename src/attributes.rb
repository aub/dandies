class Attributes
  def initialize
    plant_count_random = rand
    plant_count = 1
    plant_count = 2 if plant_count_random > 0.75
    plant_count = 3 if plant_count_random > 0.9
    plant_count = 4 if plant_count_random > 0.98

    @attributes = {
      one_plant: plant_count == 1,
      two_plants: plant_count == 2,
      three_plants: plant_count == 3,
      four_plants: plant_count == 4,
      plant_count: plant_count,
      splats: rand <= 0.75,
      big_contrast: rand > 0.9
    }
  end

  def plant_count
    @attributes[:plant_count]
  end

  def splats?
    @attributes[:splats]
  end

  def big_contrast?
    @attributes[:big_contrast]
  end
end
