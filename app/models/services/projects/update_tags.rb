require 'git'

module Services
  module Projects
    class UpdateTags < Services::Base
      def call(project)
        git = Git.open(project.local_path)
        git.fetch 'origin', tags: true
        tags = git.tags.each_with_object({}) do |tag, hash|
          hash[tag.name] = git.gcommit(tag.sha).date
        end
        # Sort tags by date
        tags = Hash[*tags.sort_by(&:last).reverse.flatten]
        project.tags = tags
        project.save!
        project
      end
    end
  end
end
