require 'spec_helper'
require 'json'

describe Bettery::Client do
  before do
    Bettery.reset!
  end

  after do
    Bettery.reset!
  end

  describe "module configuration" do
    before do
      Bettery.reset!
      Bettery.configure do |config|
        Bettery::Configurable.keys.each do |key|
          config.send("#{key}=", "Some #{key}")
        end
      end
    end

    after do
      Bettery.reset!
    end

    it "inherits the module configuration" do
      client = Bettery::Client.new
      Bettery::Configurable.keys.each do |key|
        expect(client.instance_variable_get(:"@#{key}")).to eq("Some #{key}")
      end
    end

    describe "with class level configuration" do
      before do
        @opts = {
          connection_options: {ssl: {verify: false}},
          per_page: 40
        }
      end

      it "overrides module configuration" do
        client = Bettery::Client.new(@opts)
        expect(client.per_page).to eq(40)
      end

      it "can set configuration after initialization" do
        client = Bettery::Client.new
        client.configure do |config|
          @opts.each do |key, value|
            config.send("#{key}=", value)
          end
        end
      end
    end
  end

  describe ".agent" do
    before do
      Bettery.reset!
    end

    it "acts like a Sawyer agent" do
      expect(Bettery.client.agent).to respond_to :start
    end

    it "caches the agent" do
      agent = Bettery.client.agent
      expect(agent.object_id).to eq(Bettery.client.agent.object_id)
    end
  end # .agent

  describe ".last_response", :vcr do
    it "caches the last agent response" do
      Bettery.reset!
      client = Bettery.client
      expect(client.last_response).to be_nil
      client.get "projects.json"
      expect(client.last_response.status).to eq(200)
    end
  end # .last_response

  describe ".get", :vcr do
    before(:each) do
      Bettery.reset!
    end

    it "handles query params" do
      Bettery.get "projects.json", foo: "bar"
      assert_requested :get, "https://api.betterplace.org/de/api_v4/projects.json?foo=bar"
    end

    it "handles headers" do
      request = stub_get("zen").
        with(query: {foo: "bar"}, headers: {accept: "text/plain"})
      Bettery.get "zen", foo: "bar", accept: "text/plain"
      assert_requested request
    end
  end # .get

  describe ".head", :vcr do
    it "handles query params" do
      Bettery.reset!
      Bettery.head "projects.json", foo: "bar"
      assert_requested :head, "https://api.betterplace.org/de/api_v4/projects.json?foo=bar"
    end

    it "handles headers" do
      Bettery.reset!
      request = stub_head("projects.json").
        with(query: {foo: "bar"}, headers: {accept: "text/plain"})
      Bettery.head "projects.json", foo: "bar", accept: "text/plain"
      assert_requested request
    end
  end # .head

  describe "when making requests" do
    before do
      Bettery.reset!
      @client = Bettery.client
    end

    it "Accepts application/json by default" do
      VCR.use_cassette 'projects' do
        request = stub_get("projects.json").
          with(headers: {accept: "application/json"})
        @client.get "projects.json"
        assert_requested request
        expect(@client.last_response.status).to eq(200)
      end
    end

    it "allows Accept'ing another media type" do
      request = stub_get("projects.json").
        with(headers: {accept: "application/vnd.betterplace.beta.diff+json"})
      @client.get "projects.json", accept: "application/vnd.betterplace.beta.diff+json"
      assert_requested request
      expect(@client.last_response.status).to eq(200)
    end

    it "sets a default user agent" do
      request = stub_get("projects.json").
        with(headers: {user_agent: Bettery::Default.user_agent})
      @client.get "projects.json"
      assert_requested request
      expect(@client.last_response.status).to eq(200)
    end

    it "sets a custom user agent" do
      user_agent = "Mozilla/5.0 I am Spartacus!"
      request = stub_get("projects.json").
        with(headers: {user_agent: user_agent})
      client = Bettery::Client.new(user_agent: user_agent)
      client.get "projects.json"
      assert_requested request
      expect(client.last_response.status).to eq(200)
    end

    it "sets a proxy server" do
      Bettery.configure do |config|
        config.proxy = 'http://proxy.example.com:80'
      end
      conn = Bettery.client.send(:agent).instance_variable_get(:"@conn")
      expect(conn.proxy[:uri].to_s).to eq('http://proxy.example.com')
    end

    it "passes along request headers for POST" do
      headers = {"X-Betterplace-Foo" => "bar"}
      request = stub_post("projects.json").
        with(headers: headers).
        to_return(status: 201)
      client = Bettery::Client.new
      client.post "projects.json", headers: headers
      assert_requested request
      expect(client.last_response.status).to eq(201)
    end
  end

  context "error handling" do
    before do
      Bettery.reset!
      VCR.turn_off!
    end

    after do
      VCR.turn_on!
    end

    it "raises on 404" do
      stub_get('booya').to_return(status: 404)
      expect { Bettery.get('booya') }.to raise_error Bettery::NotFound
    end

    it "raises on 500" do
      stub_get('boom').to_return(status: 500)
      expect { Bettery.get('boom') }.to raise_error Bettery::InternalServerError
    end

    it "includes a message" do
      stub_get('boom').
        to_return \
        status: 404,
        headers: {
          content_type: "application/json",
        },
        body: {message: "Couldn't find Project with id=boom"}.to_json
      begin
        Bettery.get('boom')
      rescue Bettery::NotFound => e
        expect(e.message).to include("GET https://api.betterplace.org/de/api_v4/boom: 404 - Couldn't find Project with id=boom")
      end
    end

    it "includes all error info" do
      stub_get('boom').
        to_return \
        status: 404,
        headers: {
          content_type: "application/json",
        },
        body: {
          name: "GeneralError",
          reason: "Record Not Found",
          backtrace: [
            "/path/to/file:23:in `method'",
            "/path/to/file:42:in `method2'"
          ],
          message: "Couldn't find Project with id=666"
        }.to_json
      begin
        Bettery.get('boom')
      rescue Bettery::NotFound => e
        expect(e.message).to include("GET https://api.betterplace.org/de/api_v4/boom: 404 - Error: GeneralError")
        expect(e.message).to include("Record Not Found")
        expect(e.message).to include("Couldn't find Project with id=666")
        expect(e.message).to include("/path/to/file:23:in `method'")
        expect(e.message).to include("/path/to/file:42:in `method2'")
      end
    end

    it "raises Forbidden on 403" do
      stub_get('some/admin/stuffs').to_return(status: 403)
      expect { Bettery.get('some/admin/stuffs') }.to raise_error Bettery::Forbidden
    end

    it "handle an error with a text body" do
      stub_get('boom').to_return \
        status: 400,
        body: "Client error"
      begin
        Bettery.get('boom')
      rescue Bettery::BadRequest => e
        expect(e.message).to include("Client error")
      end
    end

    it "raises on unknown client errors" do
      stub_get('user').to_return \
        status: 418,
        headers: {
          content_type: "application/json",
        },
        body: {message: "I'm a teapot"}.to_json
      expect { Bettery.get('user') }.to raise_error Bettery::ClientError
    end

    it "raises on unknown server errors" do
      stub_get('user').to_return \
        status: 509,
        headers: {
          content_type: "application/json",
        },
        body: {message: "Bandwidth exceeded"}.to_json
      expect { Bettery.get('user') }.to raise_error Bettery::ServerError
    end

    it "raises Bettery::BadGateway on 502 server errors" do
      stub_get('user').to_return \
        status: 502,
        headers: {
          content_type: "application/json",
        },
        body: {message: "BadGateway"}.to_json
      expect { Bettery.get('user') }.to raise_error Bettery::BadGateway
    end

    it "raises Bettery::ServiceUnavailable on 503 server errors" do
      stub_get('user').to_return \
        status: 503,
        headers: {
          content_type: "application/json",
        },
        body: {message: "Service Unavailable"}.to_json
      expect { Bettery.get('user') }.to raise_error Bettery::ServiceUnavailable
    end

    it "handles an error response with an array body" do
      stub_get('user').to_return \
        status: 500,
        headers: {
          content_type: "application/json"
        },
        body: [].to_json
      expect { Bettery.get('user') }.to raise_error Bettery::ServerError
    end
  end
end
