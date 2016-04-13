module JobMetadata
  module SetAccessors
    def items_for_set(set_name)
      client.items_for_set(key_for_set(set_name))
    end

    def caridnality_of_set(set_name)
      client.cardinality_of_set(key_for_set(set_name))
    end

    def remove_from_set(set_name, items)
      client.remove_from_set(key_for_set(set_name), items)
    end

    def add_to_set(set_name, items)
      client.add_to_set(key_for_set(set_name), items)
    end

    def remove_set(set_name)
      client.remove_from_set(key_for_set(set_name))
    end
  end
end
