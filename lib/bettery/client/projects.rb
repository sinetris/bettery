module Bettery
  class Client

    # Methods for the Projects API
    #
    # @see https://github.com/betterplace/betterplace_apidocs
    module Projects

      # Check if a project exists
      #
      # @see https://github.com/betterplace/betterplace_apidocs
      # @param project [Integer, String, Hash, Project] A Betterplace project
      # @return true if a project exists, false otherwise
      def project?(project, options = {})
        !!project(project, options)
      rescue Bettery::NotFound
        false
      end

      # Get a single project
      #
      # @see https://github.com/betterplace/betterplace_apidocs
      # @param project [Integer, String, Hash, Project] A Betterplace project
      # @return [Sawyer::Resource] Project information
      def project(project, options = {})
        get Bettery::Project.path(project), options
      end

      # List all projects
      #
      # This provides a dump of every project, in the order that they were
      # created.
      #
      # @see https://github.com/betterplace/betterplace_apidocs
      #
      # @param options [Hash] Optional options
      # @option options [Integer] :since The integer ID of the last Project
      #   that you’ve seen.
      # @return [Sawyer::Resource] List of projects.
      def projects(options = {})
        get 'projects.json', options
      end
    end
  end
end
