require 'bettery/response/raise_error'
require 'bettery/version'

module Bettery

  # Default configuration options for {Client}
  module Default

    # Default API endpoint
    API_BASE_ENDPOINT = "https://api.betterplace.org"

    # Default User Agent header string
    USER_AGENT        = "Bettery Ruby Gem #{Bettery::VERSION}"

    # Default media type
    MEDIA_TYPE        = "application/json"

    # Default localization
    LOCALE            = "de"

    # Default Faraday middleware stack
    MIDDLEWARE = Faraday::RackBuilder.new do |builder|
      builder.use Bettery::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[Bettery::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Default locale from ENV or {LOCALE}
      # @return [String]
      def locale
        ENV['BETTERY_LOCALE'] || LOCALE
      end

      # Default API base endpoint from ENV or {API_BASE_ENDPOINT}
      # @return [String]
      def api_base_endpoint
        ENV['BETTERY_API_BASE_ENDPOINT'] || API_BASE_ENDPOINT
      end

      # Default options for Faraday::Connection
      # @return [Hash]
      def connection_options
        {
          headers: {
            accept: default_media_type,
            user_agent: user_agent
          }
        }
      end

      # Default media type from ENV or {MEDIA_TYPE}
      # @return [String]
      def default_media_type
        ENV['BETTERY_DEFAULT_MEDIA_TYPE'] || MEDIA_TYPE
      end

      # Default middleware stack for Faraday::Connection
      # from {MIDDLEWARE}
      # @return [String]
      def middleware
        MIDDLEWARE
      end

      # Default pagination page size from ENV
      # @return [Fixnum] Page size
      def per_page
        page_size = ENV['BETTERY_PER_PAGE']

        page_size.to_i if page_size
      end

      # Default proxy server URI for Faraday connection from ENV
      # @return [String]
      def proxy
        ENV['BETTERY_PROXY']
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        ENV['BETTERY_USER_AGENT'] || USER_AGENT
      end
    end
  end
end
