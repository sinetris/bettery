module Bettery
  class Project
    attr_accessor :id
    REGEXP = /\Ahttps?.+\/projects\/(?<id>\d+).*\z/

    def initialize(project)
      case project
      when Integer
        @id = project
      when String
        @id = extract_id_from_url(project)
      when Project
        @id = project.id
      when Hash
        @id = project[:id]
      end
    end

    # @return [String] Project API path
    def path
      "projects/#{id}.json"
    end

    # Get the api path for a project
    # @param project [Integer, String, Hash, Project] A Betterplace project.
    # @return [String] Api path.
    def self.path project
      new(project).path
    end

    # Project URL based on {Bettery::Client#api_endpoint}
    # @return [String]
    def url
      File.join(Bettery.api_endpoint, path)
    end

    private

    def extract_id_from_url(url)
      if match = REGEXP.match(url)
        match[:id].to_i
      end
    end
  end
end
