class AlertMailer < ApplicationMailer
  self.delivery_job = AlertMailerJob
  add_template_helper(DatesHelper)

  def alert(subscription_id, vacancy_ids)
    @subscription = Subscription.find(subscription_id)
    vacancies = Vacancy.where(id: vacancy_ids).order(:expires_on).order(:expiry_time)

    @vacancies = VacanciesPresenter.new(vacancies)
    template = @subscription.daily? ? NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE : NOTIFY_SUBSCRIPTION_WEEKLY_TEMPLATE

    view_mail(
      template,
      to: @subscription.email,
      subject: I18n.t('job_alerts.alert.email.subject'),
    )
  end
end
