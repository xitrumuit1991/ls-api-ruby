# encoding: utf-8

class RoomThumbUploader < CarrierWave::Uploader::Base

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

  version :thumb do
    process :rails_admin_crop
    process resize_to_fill: [263, 183]
  end

  version :thumb_mb do
    process :rails_admin_crop
    process resize_to_fill: [1080, 607]
  end

  version :web_240x135 do
    process :rails_admin_crop
    process resize_to_fill: [240, 135]
  end

  version :web_retina_320x180 do
    process :rails_admin_crop
    process resize_to_fill: [320, 180]
  end

  version :app_a_1x_320x180 do
    process :rails_admin_crop
    process resize_to_fill: [320, 180]
  end

  version :app_a_15x_320x180 do
    process :rails_admin_crop
    process resize_to_fill: [320, 180]
  end

  version :app_a_2x_720x405 do
    process :rails_admin_crop
    process resize_to_fill: [720, 405]
  end

  version :app_a_3x_960x540 do
    process :rails_admin_crop
    process resize_to_fill: [960, 540]
  end

  version :app_a_4x_960x540 do
    process :rails_admin_crop
    process resize_to_fill: [960, 540]
  end

  version :app_ios_2x_720x405 do
    process :rails_admin_crop
    process resize_to_fill: [720, 405]
  end

  version :app_ios_3x_960x540 do
    process :rails_admin_crop
    process resize_to_fill: [960, 540]
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

  def rails_admin_crop
    return unless model.rails_admin_cropping?
    manipulate! do |img|
      ::RailsAdminJcrop::ImageHelper.crop(img, model.crop_w, model.crop_h, model.crop_x, model.crop_y)
      img
    end
  end
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
