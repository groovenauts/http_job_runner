FactoryGirl.define do
  factory :delayed_job, class: 'Delayed::Job' do
    priority 0
    attempts 0
    handler [
      '--- !ruby/object:Delayed::PerformableMethod',
      "object: !ruby/module 'LoggerPipe'",
      'method_name: :run',
      'args:',
      '- date',
    ].join("\n")
    last_error nil
    run_at "2016-04-20 10:45:20"
    locked_at nil
    failed_at nil
    locked_by nil
    queue nil
    created_at "2016-04-20 10:45:20"
    updated_at "2016-04-20 10:45:20"
  end
end
