require 'spec_helper'

describe Bettery do
  before do
    Bettery.reset!
  end

  after do
    Bettery.reset!
  end

  it 'has a version number' do
    expect(Bettery::VERSION).not_to be nil
  end

  it "sets defaults" do
    Bettery::Configurable.keys.each do |key|
      expect(Bettery.instance_variable_get(:"@#{key}")).to eq(Bettery::Default.send(key))
    end
  end

  describe ".client" do
    it "creates an Bettery::Client" do
      expect(Bettery.client).to be_kind_of Bettery::Client
    end

    it "caches the client when the same options are passed" do
      expect(Bettery.client).to eq(Bettery.client)
    end

    it "returns a fresh client when options are not the same" do
      client = Bettery.client
      Bettery.locale = "en"
      client_two = Bettery.client
      client_three = Bettery.client
      expect(client).not_to eq(client_two)
      expect(client_three).to eq(client_two)
    end
  end

  describe ".configure" do
    Bettery::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub('_', ' ')}" do
        Bettery.configure do |config|
          config.send("#{key}=", key)
        end
        expect(Bettery.instance_variable_get(:"@#{key}")).to eq(key)
      end
    end
  end
end
