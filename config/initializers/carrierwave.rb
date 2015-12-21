# if Rails.env.production?
  CarrierWave.configure do |config|
    config.root = Rails.root.join('tmp')
    config.cache_dir = 'carrierwave'
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider => "AWS",
      :aws_access_key_id => "AKIAJ4IUIOTMD556KNHA",
      :aws_secret_access_key => "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",
      :region                 => "ap-southeast-1"
    }
    config.fog_directory = "rubyjolapp"
    # config.fog_public     = false                                   # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
    end
# end