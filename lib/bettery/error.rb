module Bettery
  # Custom error class for rescuing from all Betterplace errors
  class Error < StandardError

    # Returns the appropriate Bettery::Error sublcass based
    # on status and response message
    #
    # @param [Hash] response HTTP response
    # @return [Bettery::Error]
    def self.from_response(response)
      status  = response[:status].to_i
      body    = response[:body].to_s
      headers = response[:response_headers]

      if klass =  case status
                  when 400      then Bettery::BadRequest
                  when 403      then Bettery::Forbidden
                  when 404      then Bettery::NotFound
                  when 400..499 then Bettery::ClientError
                  when 500      then Bettery::InternalServerError
                  when 502      then Bettery::BadGateway
                  when 503      then Bettery::ServiceUnavailable
                  when 500..599 then Bettery::ServerError
                  end
        klass.new(response)
      end
    end

    def initialize(response=nil)
      @response = response
      super(build_error_message)
    end

    private

    def data
      @data ||=
        if (body = @response[:body]) && !body.empty?
          if body.is_a?(String) &&
            @response[:response_headers] &&
            @response[:response_headers][:content_type] =~ /json/

            Sawyer::Agent.serializer.decode(body)
          else
            body
          end
        else
          nil
        end
    end

    def response_message
      case data
      when Hash
        data[:message]
      when String
        data
      end
    end

    def response_error_name
      "Error: #{data[:name]}" if data.is_a?(Hash) && data[:name]
    end

    def response_error_reason
      data[:reason] if data.is_a?(Hash) && data[:reason]
    end

    def response_error_backtrace
      return nil unless data.is_a?(Hash) && !Array(data[:backtrace]).empty?

      summary = "\nError backtrace:\n"
      summary << data[:backtrace].join("\n")

      summary
    end

    def build_error_message
      return nil if @response.nil?

      message =  "#{@response[:method].to_s.upcase} "
      message << "#{@response[:url]}: "
      message << "#{@response[:status]} - "
      message << "#{response_error_name}\n" unless response_error_name.nil?
      message << "#{response_error_reason}\n" unless response_error_reason.nil?
      message << "#{response_message}\n" unless response_message.nil?
      message << "#{response_error_backtrace}" unless response_error_backtrace.nil?
      message
    end
  end

  # Raised on errors in the 400-499 range
  class ClientError < Error; end

  # Raised when Betterplace returns a 400 HTTP status code
  class BadRequest < ClientError; end

  # Raised when Betterplace returns a 403 HTTP status code
  class Forbidden < ClientError; end

  # Raised when Betterplace returns a 404 HTTP status code
  class NotFound < ClientError; end

  # Raised on errors in the 500-599 range
  class ServerError < Error; end

  # Raised when Betterplace returns a 500 HTTP status code
  class InternalServerError < ServerError; end

  # Raised when Betterplace returns a 502 HTTP status code
  class BadGateway < ServerError; end

  # Raised when Betterplace returns a 503 HTTP status code
  class ServiceUnavailable < ServerError; end
end
