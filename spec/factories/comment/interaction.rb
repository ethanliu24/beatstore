FactoryBot.define do
  factory :comment_interaction, class: "Comment::Interaction" do
    association :user
    association :comment
    interaction_type { "like" }
  end
end
