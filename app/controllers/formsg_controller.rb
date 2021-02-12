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
    # Get just the responses as a Hash
    result_hash = Formsg::Sdk::SubmissionService.decrypt_for(data: payload)
    Rails.logger.info "Submission Result (Hash): #{result_hash.inspect}"

    # Get the Submission & Responses as an object
    submission = Formsg::Sdk::SubmissionService.build_from(data: payload)
    Rails.logger.info "Submission Result (Object): #{submission.inspect}"

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
