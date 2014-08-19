require 'spec_helper'

describe Bettery::Project do
  describe ".path" do
    context "with project id" do
      it "returns the url path" do
        project = Bettery::Project.new(12345)
        expect(project.path).to eq 'projects/12345.json'
      end
    end
  end # .path

  describe "self.path" do
    it "returns the api path" do
      expect(Bettery::Project.path(12345)).to eq 'projects/12345.json'
    end
  end

  context "when passed an integer" do
    it "sets the project id" do
      project = Bettery::Project.new(12345)
      expect(project.id).to eq 12345
    end
  end

  context "when passed a hash" do
    it "sets the project id" do
      project = Bettery::Project.new({id: 12345})
      expect(project.id).to eq(12345)
    end
  end

  context "when passed a String" do
    it "sets the project id from a website url" do
      project = Bettery::Project.new("https://betterplace.org/en/projects/12345-friendly-title")
      expect(project.id).to eq 12345
    end
    it "sets the project id from an API url" do
      project = Bettery::Project.new("https://api.betterplace.org/de/api_v4/projects/12345.json")
      expect(project.id).to eq 12345
    end
  end

  context "when passed a Project" do
    it "sets the project id" do
      project = Bettery::Project.new(Bettery::Project.new(12345))
      expect(project.id).to eq(12345)
      expect(project.url).to eq('https://api.betterplace.org/de/api_v4/projects/12345.json')
    end
  end
end
