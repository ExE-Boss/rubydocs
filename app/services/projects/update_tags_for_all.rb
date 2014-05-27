module Services
  module Projects
    class UpdateTagsForAll < Services::Base
      recurrence { hourly }
      check_uniqueness!

      def call
        Project.find_each do |project|
          Services::Projects::UpdateTags.perform_async project.id
        end
      end
    end
  end
end
