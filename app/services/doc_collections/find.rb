module DocCollections
  class Find < Services::Query
    TIMESTAMP_CONDITIONS = %i(created updated generated uploaded).product(%i(before after)).map do |timestamp, modifier|
      [timestamp, modifier].join('_').to_sym
    end

    private def process(scope, conditions)
      conditions.each do |k, v|
        case k
        when :slug
          scope = scope.where(k => v)
        when :generated_at, :uploaded_at
          scope = if v == true
            scope.where("doc_collections.#{k} IS NOT NULL")
          else
            scope.where(k => v)
          end
        when *TIMESTAMP_CONDITIONS
          timestamp, modifier = k.to_s.split('_')
          scope = scope.where("doc_collections.#{timestamp}_at #{modifier == 'before' ? '<' : '>'} ?", v)
        when :docs
          scope = scope
            .joins(:doc_collection_memberships)
            .where(doc_collection_memberships: { doc_id: v })
            .where(
              DocCollectionMembership
                .where('doc_collection_id = doc_collections.id')
                .where('doc_id NOT IN (?)', v)
                .exists.not
            )
            .group('doc_collection_memberships.doc_collection_id, doc_collections.id')
            .having('COUNT(doc_collection_memberships.doc_id) = ?', v.size)
        when /\A(.+)_not\z/
          Array(v).each do |value|
            scope.where!(value.nil? ? "doc_collections.#{$1} IS NOT NULL" : ["doc_collections.#{$1} != ?", value])
          end
        when :only_one_doc
          ids = DocCollection.joins(:docs).group('doc_collections.id').having('COUNT(docs.id) = 1')
          if v
            scope.where!(id: ids)
          else
            scope = scope.where.not(id: ids)
          end
        else
          raise ArgumentError, "Unexpected condition: #{k}"
        end
      end
      scope
    end
  end
end
