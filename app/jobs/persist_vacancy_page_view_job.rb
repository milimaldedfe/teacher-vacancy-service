class PersistVacancyPageViewJob < ApplicationJob
  queue_as :page_view_collector

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    VacancyPageView.new(vacancy).persist!
  end
end
