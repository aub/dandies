require_relative "color"
require_relative "splat"
require_relative "splat_splash"

class Watercolor
  WATERCOLOR_X_MIN = -100
  WATERCOLOR_X_MAX = Constants::IMAGE_WIDTH + 100
  WATERCOLOR_STRIPE_COUNT = 3
  WATERCOLOR_STRIPE_OVERLAP = 100

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

    palette = @attributes.palette
    @final_image = Magick::ImageList.new
    @final_image.new_image(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) do
      self.background_color = "##{Color.random_color(palette: palette, green: true).to_rgb}"
    end

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

    if @attributes.splats?
      splat_count = Util.random_watercolor_splat_count

      splat_color = Color.random_color(palette: @attributes.palette).to_rgb

      splat_count.times do
        x_position = rand * Constants::IMAGE_WIDTH
        y_position = rand * Constants::IMAGE_HEIGHT

        shape = Splat.new(
          center: Point.new(x: x_position, y: y_position),
          color: splat_color
        )
        stack = shape.to_polygon_stack
        splat_blob_collections << stack.blobs

        if @attributes.splashes?
          splash_count = ((rand * 10.0) + 10.0).round
          splash_count.times do
            angle = (0..359).to_a.sample
            distance = (rand * 40.0) + 20.0
            splash_x = x_position + (distance * Util.cos_deg(angle))
            splash_y = y_position + (distance * Util.sin_deg(angle))

            shape = SplatSplash.new(
              center: Point.new(x: splash_x, y: splash_y),
              color: splat_color
            )
            stack = shape.to_polygon_stack
            splat_blob_collections << stack.blobs
          end
        end
      end
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

    # if Constants::SAVE_COMPONENT_IMAGES
    @final_image.write("watercolor#{@image_number}.png") { self.format = "png" }
    # end
  end

  private

  def render_stripes
    WATERCOLOR_STRIPE_COUNT.times do |idx|
      stripe_height = Constants::IMAGE_HEIGHT / WATERCOLOR_STRIPE_COUNT

      color = Color.random_color(palette: @attributes.palette, green: true).to_rgb

      shape = Rectangle.new(
        upper_left: Point.new(
          x: WATERCOLOR_X_MIN,
          y: (idx * stripe_height) - WATERCOLOR_STRIPE_OVERLAP
        ),
        width: WATERCOLOR_X_MAX - WATERCOLOR_X_MIN,
        height: stripe_height + (2.0 * WATERCOLOR_STRIPE_OVERLAP),
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

      color = Color.random_color(palette: @attributes.palette).to_rgb

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
