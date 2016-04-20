FactoryGirl.define do
  factory :delayed_job, class: 'Delayed::Job' do
    priority 1
    attempts 1
    handler "MyText"
    last_error "MyText"
    run_at "2016-04-20 10:45:20"
    locked_at "2016-04-20 10:45:20"
    failed_at "2016-04-20 10:45:20"
    locked_by "MyString"
    queue "MyString"
    created_at "2016-04-20 10:45:20"
    updated_at "2016-04-20 10:45:20"
  end
end
