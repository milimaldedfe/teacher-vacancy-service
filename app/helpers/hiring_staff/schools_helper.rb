module HiringStaff::SchoolsHelper
  def table_header_sort_by(title, type, column:, sort:)
    order = column == sort.column ? sort.reverse_order : sort.order
    extra_classes = "sortby--#{order}"
    extra_classes += " active" if column == sort.column

    link_to title,
            jobs_with_type_organisation_path(type, school_vacancy_params(sort_column: column, sort_order: order)),
            class: "govuk-link sortable-link #{extra_classes}",
            'aria-label': t("jobs.aria_labels.sort_by_link", column: title, order: order)
  end

  def school_vacancy_params_whitelist
    %i[sort_column sort_order]
  end

  def school_vacancy_params(overwrite = {})
    params.merge(overwrite).permit(school_vacancy_params_whitelist)
  end

  def awaiting_feedback_tab(count)
    if count.zero?
      t("jobs.awaiting_feedback_jobs")
    else
      content_tag :span do
        content_tag(:span, t("jobs.awaiting_feedback_jobs")) +
          content_tag(:span, count, class: "notification", data: { test: "expired-vacancies-with-feedback-outstanding" })
      end
    end
  end
end
