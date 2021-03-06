class HiringStaff::Vacancies::JobLocationController < HiringStaff::Vacancies::ApplicationController
  before_action :verify_school_group
  before_action :set_up_url
  before_action only: %i[create update] do
    set_up_form(JobLocationForm)
  end

  def show
    attributes = @vacancy.present? ? @vacancy.attributes : (session[:vacancy_attributes]&.symbolize_keys || {})
    @form = JobLocationForm.new(attributes)
  end

  def create
    @form.vacancy.readable_job_location = readable_job_location(@form.vacancy.job_location)
    store_vacancy_attributes(@form.vacancy.attributes)
    session[:vacancy_attributes]["organisation_id"] = current_organisation.id
    if @form.valid?
      redirect_to_next_step_if_continue(@vacancy&.persisted? ? @vacancy.id : session_vacancy_id)
    else
      render :show
    end
  end

  def update
    if @form.valid?
      @vacancy.update(readable_job_location: readable_job_location(@form.vacancy.job_location))
      set_organisations(@vacancy, [current_school_group.id]) if @form.job_location == "central_office"
      update_vacancy(form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      redirect_to_school_selection_or_next_step
    else
      render :show
    end
  end

private

  def form_submission_path(vacancy_id)
    vacancy_id.present? ? organisation_job_job_location_path(vacancy_id) : job_location_organisation_job_path
  end

  def form_params
    (params[:job_location_form] || params).permit(:state, :job_location).merge(completed_step: current_step)
  end

  def next_step
    vacancy_id = @vacancy&.persisted? ? @vacancy.id : session_vacancy_id
    if %w[at_one_school at_multiple_schools].include?(@form.job_location)
      vacancy_id.present? ? organisation_job_schools_path(vacancy_id) : schools_organisation_job_path
    elsif @form.job_location == "central_office"
      vacancy_id.present? ? organisation_job_job_specification_path(vacancy_id) : job_specification_organisation_job_path
    end
  end

  def redirect_to_school_selection_or_next_step
    if @vacancy.state != "create" && %w[at_one_school at_multiple_schools].include?(@form.job_location)
      redirect_to organisation_job_schools_path(@vacancy.id)
    else
      redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    end
  end
end
