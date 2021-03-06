class GeneralFeedback < ApplicationRecord
  include FeedbackValidations

  enum visit_purpose: { other_purpose: 0, find_teaching_job: 1, list_teaching_job: 2 }
  enum user_participation_response: { interested: 0, not_interested: 1 }

  validates :visit_purpose, presence: true

  validates :visit_purpose_comment, length: { maximum: 1200 }, if: :visit_purpose_comment?

  scope :published_on, (->(date) { where(created_at: date.all_day) })
end
