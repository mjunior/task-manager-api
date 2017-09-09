FactoryGirl.define do
  factory :task do
    title "MyString"
    description "MyText"
    done false
    deadline "2017-09-09 20:49:36"
    user nil
  end
end
