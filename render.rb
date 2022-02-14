# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'byebug'
require 'RMagick'

require_relative 'src/attributes'
require_relative 'src/circle'
require_relative 'src/constants'
require_relative 'src/gap'
require_relative 'src/leaf_image'
require_relative 'src/plant_collection'
require_relative 'src/rectangle'
require_relative 'src/splat'
require_relative 'src/watercolor'

SHADOW_OFFSET = 7

def render_image(attributes:, image_number:)
  watercolor = Watercolor.new(attributes: attributes, image_number: image_number)
  plant_collection = PlantCollection.new(attributes: attributes, image_number: image_number)

  final_image = Magick::Image.new(Constants::IMAGE_WIDTH, Constants::IMAGE_HEIGHT) do
    self.background_color = "##{Color.random_color(background: true, palette: attributes.palette).to_rgb}"
  end

  final_image = final_image.composite(
    plant_collection.shadow_image,
    SHADOW_OFFSET,
    SHADOW_OFFSET,
    Magick::OverCompositeOp
  )

  final_image.mask(plant_collection.plants_image)
  final_image = final_image.composite(
    watercolor.get_image,
    0,
    0,
    Magick::AtopCompositeOp
  )

  final_image.write("image-precrop.png") do
    self.format = 'png'
  end

  img = Magick::Image.read("image-precrop.png")[0]

  img.crop!(
    25,
    25,
    Constants::IMAGE_WIDTH - 25,
    Constants::IMAGE_HEIGHT - 25 
  )

  img.write("image#{image_number}.png") do
    self.format = 'png'
  end
end

1.upto(1) do |idx|
  attributes = Attributes.new
  puts "Rendering image #{idx}"
  puts attributes.inspect
  render_image(attributes: attributes, image_number: idx)
end
