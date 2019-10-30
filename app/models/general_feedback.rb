class GeneralFeedback < ApplicationRecord
  include Auditor::Model
  include FeedbackValidations

  enum visit_purpose: { other_purpose: 0, find_teaching_job: 1, list_teaching_job: 2 }
  enum user_participation_response: { interested: 0, not_interested: 1 }

  validates :visit_purpose, presence: { message: 'Enter the reason for your visit' }

  validates :visit_purpose_comment, length: \
    { maximum: 1200, message: 'Purpose of visit must not be more than 1,200 characters' }, if: :visit_purpose_comment?

  scope :published_on, (->(date) { where(created_at: date.all_day) })

  def to_row
    [
      Time.zone.now.to_s,
      visit_purpose,
      visit_purpose_comment,
      rating,
      comment,
      created_at.to_s,
      user_participation_response,
      email
    ]
  end
end
