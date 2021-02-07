Formsg::Sdk.configure do |config|
  config.default_public_key = ENV["FORMSG_PUBLIC_KEY"]
  config.default_form_secret_key = ENV["FORMSG_FORM_SECRET_KEY"]
  config.default_post_uri = ENV["FORMSG_POST_URI"]
end