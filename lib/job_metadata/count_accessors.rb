module JobMetadata
  module CountAccessors
    def increment_count_by(count_name, amount)
      JobMetadata.client.increment_count_by(key_for_count(count_name), amount)
    end

    def count(count_name)
      JobMetadata.client.count(key_for_count(count_name))
    end

    def remove_count(count_name)
      JobMetadata.client.remove_count(key_for_count(count_name))
    end
  end
end
