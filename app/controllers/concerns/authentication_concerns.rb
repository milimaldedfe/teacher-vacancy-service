module AuthenticationConcerns
  extend ActiveSupport::Concern

  included do
    helper_method :authenticated?
    helper_method :current_organisation
    helper_method :current_school
    helper_method :current_school_group
    helper_method :school_group_user?
  end

  def authenticated?
    session.key?(:session_id)
  end

  def current_organisation
    current_school || current_school_group
  end

  def current_school
    @current_school ||= School.find_by!(urn: session[:urn]) if session[:urn].present?
  end

  def current_school_group
    if session[:uid].present?
      @current_school_group ||= SchoolGroup.find_by!(uid: session[:uid])
    elsif LocalAuthorityAccessFeature.enabled? && session[:la_code].present?
      @current_school_group ||= SchoolGroup.find_by!(local_authority_code: session[:la_code])
    end
  end

  def school_group_user?
    session[:uid].present? || session[:la_code].present?
  end
end
