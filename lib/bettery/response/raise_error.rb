require 'faraday'
require 'bettery/error'

module Bettery
  # Faraday response middleware
  module Response

    # This class raises an Bettery-flavored exception based
    # HTTP status codes returned by the API
    class RaiseError < Faraday::Response::Middleware

      private

      def on_complete(response)
        if error = Bettery::Error.from_response(response)
          raise error
        end
      end
    end
  end
end
