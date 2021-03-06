module Docs
  class CreateGitFiles < Services::Base
    def call(doc)
      check_uniqueness doc.project.id
      git = Git.open(doc.project.local_path)
      git.checkout doc.tag
      if File.exist?(doc.local_git_path)
        FileUtils.rm_rf doc.local_git_path
      end
      FileUtils.cp_r doc.project.local_path, doc.local_git_path
    end
  end
end
