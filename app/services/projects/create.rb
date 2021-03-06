module Projects
  class Create < Services::Base
    def call(attributes)
      project = Project.create!(attributes)
      Projects::Clone.call(project)
      Projects::UpdateTags.call(project.id)
      # Reload project so that tags are visible.
      project.reload
    end
  end
end
