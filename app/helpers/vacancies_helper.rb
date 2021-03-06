module VacanciesHelper
  include VacanciesOptionsHelper
  include AddressHelper

  WORD_EXCEPTIONS = %w[and the of upon].freeze

  def format_location_name(location)
    uncapitalize_words(location.titleize)
  end

  def uncapitalize_words(location_name)
    array = location_name.split(" ")
    array.map! { |word| WORD_EXCEPTIONS.include?(word.downcase) ? word.downcase : word }
    array.join(" ")
  end

  def new_attributes(vacancy)
    attributes = {}
    attributes[:supporting_documents] = I18n.t("jobs.supporting_documents") unless vacancy.supporting_documents
    attributes[:contact_number] = I18n.t("jobs.contact_number") unless vacancy.contact_number
    attributes
  end

  def page_title_prefix(vacancy, form_object, page_heading)
    if %w[create review].include?(vacancy.state)
      "#{form_object.errors.present? ? 'Error: ' : ''}#{page_heading} — #{t('jobs.create_a_job_title', organisation: current_organisation.name)}"
    else
      "#{form_object.errors.present? ? 'Error: ' : ''}Edit the #{page_heading}"
    end
  end

  def review_page_title_prefix(vacancy, organisation = current_organisation)
    page_title = I18n.t("jobs.review_page_title", organisation: organisation.name)
    "#{vacancy.errors.present? ? 'Error: ' : ''}#{page_title}"
  end

  def review_heading(vacancy)
    return I18n.t("jobs.copy_review_heading") if vacancy.state == "copy"

    I18n.t("jobs.review_heading")
  end

  def page_title(vacancy)
    return I18n.t("jobs.copy_job_title", job_title: vacancy.job_title) if vacancy.state == "copy"
    return I18n.t("jobs.create_a_job_title", organisation: organisation_from_job_location(vacancy)) if
      %w[create review].include?(vacancy.state)

    I18n.t("jobs.edit_job_title", job_title: vacancy.job_title)
  end

  def organisation_from_job_location(vacancy)
    vacancy.job_location == "at_multiple_schools" ? "multiple schools" : vacancy.parent_organisation_name
  end

  def page_title_no_vacancy
    organisation_for_title =
      if session[:vacancy_attributes] && session[:vacancy_attributes]["job_location"] == "at_one_school"
        session[:vacancy_attributes]["readable_job_location"]
      elsif session[:vacancy_attributes] && session[:vacancy_attributes]["job_location"] == "at_multiple_schools"
        "multiple schools"
      else
        current_organisation.name
      end

    organisation_for_title ? I18n.t("jobs.create_a_job_title", organisation: organisation_for_title) : I18n.t("jobs.create_a_job_title_no_org")
  end

  def hidden_state_field_value(vacancy, copy = false)
    return "copy" if copy
    return "edit_published" if vacancy&.published?
    return vacancy&.state if %w[copy review edit].include?(vacancy&.state)

    "create"
  end

  def back_to_manage_jobs_link(vacancy)
    state = if vacancy.listed?
              "published"
            elsif vacancy.published? && vacancy.expiry_time.future?
              "pending"
            elsif vacancy.published? && vacancy.expiry_time.past?
              "expired"
            else
              "draft"
            end
    jobs_with_type_organisation_path(state)
  end

  def expiry_date_and_time(vacancy)
    format_date(vacancy.expires_on) + " at " + vacancy.expiry_time.strftime("%-l:%M %P")
  end

  def vacancy_or_organisation_description(vacancy)
    vacancy.about_school.presence || vacancy.parent_organisation.description.presence
  end

  def vacancy_about_school_label_organisation(vacancy)
    vacancy.organisations.many? ? "the schools" : vacancy.parent_organisation.name
  end

  def vacancy_about_school_hint_text(vacancy)
    if vacancy.organisations.many?
      return I18n.t("helpers.hint.job_summary_form.about_schools",
                    organisation_type: organisation_type_basic(vacancy.parent_organisation))
    end

    I18n.t("helpers.hint.job_summary_form.about_organisation",
           organisation_type: organisation_type_basic(vacancy.parent_organisation).capitalize)
  end

  def vacancy_about_school_value(vacancy)
    return "" if vacancy.organisations.many?

    vacancy_or_organisation_description(vacancy)
  end

  def vacancy_job_location(vacancy)
    organisation = vacancy.parent_organisation
    return "#{I18n.t('hiring_staff.organisations.readable_job_location.at_multiple_schools')}, #{organisation.name}" if
      vacancy&.job_location == "at_multiple_schools"

    address_join([organisation.name, organisation.town, organisation.county])
  end

  def vacancy_job_location_heading(vacancy)
    return I18n.t("school_groups.job_location_heading.#{vacancy.job_location}") unless
      vacancy.job_location == "at_multiple_schools"

    I18n.t("school_groups.job_location_heading.at_multiple_schools",
           organisation_type: organisation_type_basic(vacancy.parent_organisation))
  end

  def vacancy_school_visits_hint(vacancy)
    organisation = organisation_type_basic(vacancy.parent_organisation).gsub(" ", "_")
    I18n.t("helpers.hint.application_details_form.#{organisation}_visits")
  end
end
