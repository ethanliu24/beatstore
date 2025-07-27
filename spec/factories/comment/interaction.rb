FactoryBot.define do
  factory :comment_like, class: "Comment::Interaction" do
    association :user
    association :comment
    interaction_type { "like" }
  end

  factory :comment_dislike, class: "Comment::Interaction" do
    association :user
    association :comment
    interaction_type { "dislike" }
  end
end
