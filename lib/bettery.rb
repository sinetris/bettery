require 'bettery/client'
require 'bettery/default'

# Ruby toolkit for the Betterplace API
module Bettery
  class << self
    include Bettery::Configurable

    # API client based on configured options {Configurable}
    #
    # @return [Bettery::Client] API wrapper
    def client
      unless defined?(@client) && @client.same_options?(options)
        @client = Bettery::Client.new(options)
      end
      @client
    end

    private

    def method_missing(method_name, *args, &block)
      return super unless client.respond_to?(method_name)
      client.send(method_name, *args, &block)
    end
  end
end

Bettery.setup
