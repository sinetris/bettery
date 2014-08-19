require 'spec_helper'

describe Bettery::Client::Projects do
  before do
    Bettery.reset!
    @client = bettery_client
  end

  describe ".project", :vcr do
    it "returns the matching project" do
      project = @client.project(12345)
      expect(project.id).to eq(12345)
      expect(project.title).to eq("Finanzierung der Nachsorge")
      assert_requested :get, betterplace_url("/projects/12345.json")
    end
  end # .project

  describe ".projects", :vcr do
    it "returns projects on betterplace" do
      projects = Bettery.projects
      expect(projects.data).to be_kind_of Array
      assert_requested :get, betterplace_url("/projects.json")
    end
  end # .projects

  describe ".project?", :vcr do
    it "returns true if the project exists" do
      result = @client.project?(12345)
      expect(result).to be true
      assert_requested :get, betterplace_url("/projects/12345.json")
    end
    it "returns false if the project doesn't exist" do
      result = @client.project?(112233445566778899)
      expect(result).to be false
      assert_requested :get, betterplace_url("/projects/112233445566778899.json")
    end
  end # .project?
end
