require 'simplecov'
require 'coveralls'
require 'webmock/rspec'
require 'vcr'

WebMock.disable_net_connect!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    serialize_with: :json,
    record:         ENV['TRAVIS'] ? :none : :once
  }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bettery'

def stub_delete(url)
  stub_request(:delete, betterplace_url(url))
end

def stub_get(url)
  stub_request(:get, betterplace_url(url))
end

def stub_head(url)
  stub_request(:head, betterplace_url(url))
end

def stub_patch(url)
  stub_request(:patch, betterplace_url(url))
end

def stub_post(url)
  stub_request(:post, betterplace_url(url))
end

def stub_put(url)
  stub_request(:put, betterplace_url(url))
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_response(file)
  {
    body: fixture(file),
    headers: {
      content_type: 'application/json; charset=utf-8'
    }
  }
end

def betterplace_url(url)
  return url if url =~ /^http/

  File.join(Bettery.api_endpoint, url)
end

def bettery_client
  Bettery::Client.new
end

def use_vcr_placeholder_for(text, replacement)
  VCR.configure do |c|
    c.define_cassette_placeholder(replacement) do
      text
    end
  end
end
