Delayed::Job.class_eval do
  validates :handler, presence: true
end
