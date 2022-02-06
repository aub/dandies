class Watercolor
  def initialize(attributes:, image_number:)
    @attributes = attributes
    @image_number = image_number
    @shape_blob_collections = []
    render
  end

  def get_image
    @final_image
  end

  def render
    render_stripes
    render_circles

    @final_image = Magick::ImageList.new
    @final_image.new_image(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) { self.background_color = "white" }

    if @shape_blob_collections.any?
      gc = Magick::Draw.new
      (0..(@shape_blob_collections[0].count - 1)).to_a.each_slice(5) do |slice_indices|
        slice_indices.each do |idx|
          @shape_blob_collections.each do |collection|
            collection[idx].render(gc: gc)
          end
        end
      end
      gc.draw(@final_image)
    end

    splat_blob_collections = []

    splat_count = Util.random_watercolor_splat_count

    gos = ["4", "5", "6", "7", "8", "9", "a"]
    splat_color = "#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}#{gos.sample}"

    splat_count.times do
      x_position = rand * Constants::IMAGE_WIDTH
      y_position = rand * Constants::IMAGE_HEIGHT

      radius = Util.random_watercolor_splat_radius

      shape = Splat.new(
        center: Point.new(x: x_position, y: y_position),
        radius: radius,
        color: splat_color
      )
      stack = shape.to_polygon_stack
      splat_blob_collections << stack.blobs
    end

    spray_start_x = -100
    spray_end_x = Constants::IMAGE_WIDTH + 100
    spray_increment_min = 5
    spray_increment_max = 30
    spray_angle_min = -20.0
    spray_angle_max = 20.0
    spray_radius_min = 2.0
    spray_radius_max = 10.0
    spray_angle = (rand * (spray_angle_max - spray_angle_min)) + spray_angle_min
    spray_y_min = Constants::IMAGE_HEIGHT * 0.2
    spray_y_max = Constants::IMAGE_HEIGHT * 0.8
    spray_jitter_max = 200.0
    spray_jitter_min = -100.0
    spray_x = spray_start_x
    spray_y = (rand * (spray_y_max - spray_y_min)) + spray_y_min
    while spray_x < spray_end_x
      increment = (rand * (spray_increment_max - spray_increment_min)) + spray_increment_min
      spray_x += (Util.cos_deg(spray_angle) * increment)
      spray_y += (Util.sin_deg(spray_angle) * increment)

      jitter_x = (rand * (spray_jitter_max - spray_jitter_min)) + spray_jitter_min
      jitter_y = (rand * (spray_jitter_max - spray_jitter_min)) + spray_jitter_min

      position_x = spray_x + (Util.cos_deg(90.0 - spray_angle) * jitter_x)
      position_y = spray_y + (Util.sin_deg(90.0 - spray_angle) * jitter_y)

      radius = (rand * (spray_radius_max - spray_radius_min)) * spray_radius_min

      shape = Splat.new(
        center: Point.new(x: position_x, y: position_y),
        radius: radius,
        color: splat_color
      )
      stack = shape.to_polygon_stack
      splat_blob_collections << stack.blobs
    end

    splat_image = Magick::ImageList.new
    splat_image.new_image(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) { self.background_color = "none" }
    splat_image.alpha(Magick::ActivateAlphaChannel)
    splat_image.background_color = "none"

    if splat_blob_collections.any?
      gc = Magick::Draw.new
      (0..(splat_blob_collections[0].count - 1)).to_a.each_slice(5) do |slice_indices|
        slice_indices.each do |idx|
          splat_blob_collections.each do |collection|
            collection[idx].render(gc: gc)
          end
        end
      end
      gc.draw(splat_image)
    end

    splat_image = splat_image.blur_image(1.0, 1.0)

    if Constants::SAVE_COMPONENT_IMAGES
      splat_image.write("splats#{@image_number}.png") { self.format = "png" }
    end

    @final_image = @final_image.blur_image(5.0, 1.5)
    @final_image = @final_image.composite(
      splat_image,
      0,
      0,
      Magick::AtopCompositeOp
    )

    if Constants::SAVE_COMPONENT_IMAGES
      @final_image.write("watercolor#{@image_number}.png") { self.format = "png" }
    end
  end

  private

  def render_stripes
    Constants::WATERCOLOR_STRIPE_COUNT.times do |idx|
      stripe_height = Constants::IMAGE_HEIGHT / Constants::WATERCOLOR_STRIPE_COUNT

      gos = ["4", "5", "6", "7", "8", "9", "a", "b"]
      oos = ["0", "1", "2", "3", "4"]
      color = "#{oos.sample}#{oos.sample}#{gos.sample}#{gos.sample}#{oos.sample}#{oos.sample}"

      shape = Rectangle.new(
        upper_left: Point.new(
          x: Constants::WATERCOLOR_X_MIN,
          y: (idx * stripe_height) - Constants::WATERCOLOR_STRIPE_OVERLAP
        ),
        width: Constants::WATERCOLOR_X_MAX - Constants::WATERCOLOR_X_MIN,
        height: stripe_height + (2.0 * Constants::WATERCOLOR_STRIPE_OVERLAP),
        color: color
      )

      stack = shape.to_polygon_stack
      @shape_blob_collections << stack.blobs
    end
  end

  def render_circles
    circle_count = Util.random_watercolor_circle_count

    circle_count.times do
      x_position = rand * Constants::IMAGE_WIDTH
      y_position = rand * Constants::IMAGE_HEIGHT

      radius = Util.random_watercolor_circle_radius

      gos = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
      color = "#{gos.sample}#{gos.sample}00#{gos.sample}#{gos.sample}"

      shape = Circle.new(
        center: Point.new(x: x_position, y: y_position),
        radius: radius,
        color: color
      )
      stack = shape.to_polygon_stack
      @shape_blob_collections << stack.blobs
    end
  end
end
