FactoryBot.define do
  factory :feedback do
    rating { 1 }
    comment { 'Some feedback text' }
    vacancy
    user

    trait :old_with_no_user do
      to_create { |instance| instance.save(validate: false) }
      user { nil }
    end
  end
end
