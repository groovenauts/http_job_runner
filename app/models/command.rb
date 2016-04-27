module Command
  module_function

  def run(cmd)
    LoggerPipe.run(Rails.logger, cmd, returns: :none, logging: :both)
  end
end
