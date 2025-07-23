FactoryBot.define do
  factory :comment do
    content { "This is a comment." }
    association :user

    transient do
      entity { association(:track) }
    end

    after(:build) do |comment, evaluator|
      comment.entity = evaluator.entity
    end
  end
end
