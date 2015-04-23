require 'sdoc/merge'
require 'zip'

module Services
  module DocCollections
    class CreateFiles < Services::Base
      FolderExistsError = Class.new(Error)

      def call(id_or_object)
        doc_collection = find_object(id_or_object)
        check_uniqueness doc_collection.id

        docs = Services::Docs::Find.call([], doc_collection: doc_collection)
        raise Error, "Doc collection #{doc_collection.name} has no docs." if docs.empty?
        raise FolderExistsError, "Folder for doc collection #{doc_collection.name} already exist." if File.exist?(doc_collection.local_path)

        # Merge docs
        sdoc_merge = SDoc::Merge.new
        sdoc_options = {
          title: doc_collection.name,
          op:    doc_collection.local_path,
          names: docs.map(&:name).join(',')
        }
        sdoc_args = sdoc_options.map do |k, v|
          "--#{k}=#{v}"
        end
        sdoc_merge.merge sdoc_args.concat(docs.map(&:local_path))

        # Create zip
        Dir.chdir doc_collection.local_path do
          Zip::File.open doc_collection.zipfile, Zip::File::CREATE do |zipfile|
            Dir['**/*'].each do |file|
              zipfile.add file, file
            end
          end
          FileUtils.chmod 0644, doc_collection.zipfile
        end

        doc_collection
      end
    end
  end
end
