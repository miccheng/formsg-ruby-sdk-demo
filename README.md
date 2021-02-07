# FormSG Ruby SDK - Ruby on Rails Demo

Ruby SDK for integrating with form.gov.sg webhooks

## Pre-Requisite

Your will need to have `libsodium` (<https://github.com/jedisct1/libsodium>) installed in your hosting server. You can read up more at the installation guide for [RbNaCl](https://github.com/RubyCrypto/rbnacl).

## Usage

1. In Rails, add this as an initializer:

    ```ruby
    # config/initializers/formsg_sdk.rb

    Formsg::Sdk.configure do |config|
      config.default_public_key = "3Tt8VduXsjjd4IrpdCd7BAkdZl/vUCstu9UvTX84FWw=" # Production Public Key
      config.default_form_secret_key = "<your form's secret key>"
      config.default_post_uri = "https://example.com/submission"
    end
    ```

    _**Note**: You should probably store the tokens as environment variables._

    **Example:**

    ```ruby
    # config/initializers/formsg_sdk.rb

    Formsg::Sdk.configure do |config|
      config.default_public_key = ENV["FORMSG_PUBLIC_KEY"]
      config.default_form_secret_key = ENV["FORMSG_FORM_SECRET_KEY"]
      config.default_post_uri = ENV["FORMSG_POST_URI"]
    end
    ```

2. Add this in your controller method:

    ```ruby
    # apps/controllers/formsg_controller.rb

    class FormsgController < ApplicationController
      # You can inherit this controller from ActionController::API to avoid the CSRF token
      skip_before_action :verify_authenticity_token, only: [:submissions]

      def submissions
        # Step 1: Verify that this is a valid Webhook request from FormSG
        Formsg::Sdk::Webhook.new.authenticate(
          header: request.headers['HTTP_X_FORMSG_SIGNATURE']
        )

        # Step 2: Read the data param
        payload = submission_param
        Rails.logger.info "POST params: #{payload.inspect}"

        # Step 3: Decrypt the form submission
        result = Formsg::Sdk::Crypto.new.decrypt(data: payload)
        Rails.logger.info "Submission Result: #{result.inspect}"

        head :ok
      rescue => e
        Rails.logger.error "Invalid Submission: #{e.message}"

        head 500
      end

      private

      def submission_param
        params.require(:data)
      end
    end
    ```

3. Ensure your `routes.rb` has the new controller method.

    ```ruby
    # config/routes.rb

    post "/submissions", to: "formsg#submissions"
    ```

4. Deploy your app to your hosting server.
5. Update your FormSG's Webhook Endpoint URL.
6. Test by submitting a new form.

---

### Known Issues

1. Follow instructions at [rbnacl](https://github.com/RubyCrypto/rbnacl) on how to install the `libsodium` dependency in your development computer.

2. For MacOS, when installing `ffi`, you might run into this issue:

    >Function.c:847:17: error: implicit declaration of function 'ffi_prep_closure_loc' is invalid in C99
    
    You can fix it by adding the `--disable-system-libffi` option:
    
    ```
    gem install ffi:x.x.x -- --disable-system-libffi
    ```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opengovsg/formsg-ruby-sdk.

## License

The project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
