module EY
  class CloudClient
    class Error < RuntimeError
    end

    class RequestFailed      < Error; end
    class InvalidCredentials < RequestFailed; end
    class ResourceNotFound   < RequestFailed; end

    class BadEndpointError < Error
      def initialize(endpoint)
        super "#{endpoint.inspect} is not a valid endpoint URI. Endpoint must be an absolute URI."
      end
    end

    class ResolverError        < Error; end
    class NoMatchesError       < ResolverError; end
    class MultipleMatchesError < ResolverError; end

    class AttributeRequiredError < Error
      def initialize(attribute_name, klass = nil)
        if klass
          super "Attribute '#{attribute_name}' of class #{klass} is required for this action."
        else
          super "Attribute '#{attribute_name}' is required for this action."
        end
      end
    end

    class NoAppError < Error
      def initialize(repo, endpoint)
        super <<-ERROR
There is no application configured for any of the following remotes:
\t#{repo ? repo.urls.join("\n\t") : "No remotes found."}
You can add this application at #{endpoint}
        ERROR
      end
    end

    class InvalidAppError < Error
      def initialize(name)
        super %|There is no app configured with the name "#{name}"|
      end
    end

    class NoAppMasterError < Error
      def initialize(env_name)
        super "The environment '#{env_name}' does not have a master instance."
      end
    end

    class NoInstancesError < Error
      def initialize(env_name)
        super "The environment '#{env_name}' does not have any matching instances."
      end
    end

    class BadAppMasterStatusError < Error
      def initialize(master_status)
        super "Application master's status is not \"running\" (green); it is \"#{master_status}\"."
      end
    end

    class EnvironmentError < Error
    end

    class AmbiguousEnvironmentGitUriError < EnvironmentError
      def initialize(environments)
        message = "The repository url in this directory is ambiguous.\n"
        message << "Please use -e <envname> to specify one of the following environments:\n"
        environments.sort do |a, b|
          if a.account == b.account
            a.name <=> b.name
          else
            a.account.name <=> b.account.name
          end
        end.each { |env| message << "\t#{env.name} (#{env.account.name})\n" }
        super message
      end
    end

    class NoEnvironmentError < EnvironmentError
      def initialize(env_name, endpoint = EY::CloudClient.endpoint)
        super "No environment found matching '#{env_name}'\nYou can create one at #{endpoint}"
      end
    end

    class EnvironmentUnlinkedError < Error
      def initialize(env_name)
        super "Environment '#{env_name}' exists but does not run this application."
      end
    end
  end
end