Delayed::Job.class_eval do
  validates :command, presence: true

  def command
    case payload_object
    when Delayed::PerformableMethod then payload_object.args.first
    else "Unsupported payload object: #{payload_object.inspect}"
    end
  end

  def command=(val)
    self.payload_object = Delayed::PerformableMethod.new(LoggerPipe, :run, [val])
  end
end
