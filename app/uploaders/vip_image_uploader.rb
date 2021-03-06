# encoding: utf-8

class VipImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :w60h60 do
    process resize_to_fill: [60, 60]
  end

  version :w100h100 do
    process resize_to_fill: [100, 100]
  end

  version :w120h120 do
    process resize_to_fill: [120, 120]
  end

  version :w200h200 do
    process resize_to_fill: [200, 200]
  end

  version :w240h240 do
    process resize_to_fill: [240, 240]
  end

  version :w300h300 do
    process resize_to_fill: [300, 300]
  end

  version :w400h400 do
    process resize_to_fill: [400, 400]
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "Vip_#{@model.id}.#{file.extension}" if original_filename
  end

end
