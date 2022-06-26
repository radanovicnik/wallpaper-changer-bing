module LogHelper

  # Append to log (and to stdout if enabled)
  def self.add(logger, severity = :info, &block)
    if %i(fatal error warn info debug).include? severity
      logger.send(severity, &block)

      if CONFIG[:log][:enable_stdout]
        case severity
        when :fatal, :error
          STDERR.puts yield
        else
          puts yield
        end
      end

    end
  end

end