module Bettery
  module Configurable
    attr_accessor :api_base_endpoint, :connection_options, :default_media_type,
                  :locale, :middleware, :per_page, :proxy, :user_agent

    class << self
      def keys
        @keys ||= [
          :api_base_endpoint,
          :connection_options,
          :default_media_type,
          :locale,
          :middleware,
          :per_page,
          :proxy,
          :user_agent
        ]
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    # Reset configuration options to default values
    def reset!
      Bettery::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Bettery::Default.options[key])
      end
      self
    end
    alias setup reset!

    private

    def options
      Hash[Bettery::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end
  end
end
