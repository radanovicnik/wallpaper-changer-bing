module YamlHelper

  # Load settings from file
  def self.load_config
    config = {}
    begin
      config = YAML.load_file 'config/default.yml'
    rescue StandardError => e
      STDERR.puts "Default configuration file missing (config/default.yml)!\n#{e.full_message}"
      exit false
    end
    
    if File.exist? 'config/custom.yml'
      begin
        config.deep_merge!(YAML.load_file('config/custom.yml'))
      rescue StandardError => e
        STDERR.puts 'Unable to read custom config file (config/custom.yml).'
      end
    end

    config
  end

  # Get data about recent launches
  def self.load_recents
    recents = {}
    begin
      recents = YAML.load_file('recent.yml')
    rescue StandardError => e
      puts 'No data about recent launches. Starting to record from now.'
    end
    recents = {} unless recents.class == Hash
    recents[:history] = [] if recents[:history].nil?

    recents
  end

end