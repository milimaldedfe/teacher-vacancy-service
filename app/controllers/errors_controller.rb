class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token,
                     only: %i[not_found unprocessable_entity internal_server_error csp_violation]

  def unauthorised
    respond_to do |format|
      format.html { render status: :unauthorized }
      format.json { render json: { error: 'Not authorised' }, status: :unauthorised }
      format.all { render status: :unauthorised, body: nil }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: 'Resource not found' }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
    end
  end

  def csp_violation
    Rollbar.error('CSP Violation', details: request.raw_post)
    head :no_content
  end
end
