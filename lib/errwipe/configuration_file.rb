require 'yaml'

module Errwipe
  # Wrapper to load the configuration from a file and read individual settings
  class ConfigurationFile
    def initialize(filename)
      @filename = filename
      @config   = YAML.load_file(@filename)
    end

    def [](key)
      @config[key.to_s]
    end
  end
end
