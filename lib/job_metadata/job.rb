module JobMetadata
  class Job
    include SetAccessors
    include CountAccessors

    attr_accessor :client, :identifier

    BASE_KEY = 'batching_job'

    def initialize(client, identifier)
      @client = client
      @identifier = identifier
    end

    def new_batch_for_identifiers(identifiers)
      batch_index = increment_count_by(:batches, 1)
      add_to_set(:batches, batch_index)
      batch = Batch.new(client, identifier, batch_index)
      batch.add_to_set(:pending, identifiers)
      batch
    end

    def remove_batch(batch_index)
      remove_from_set(:batches, batch_identifier)
    end

    private

    def key_for_set(set_name)
      "#{BASE_KEY}:#{identifier}:#{set_name}"
    end

    def key_for_count(count_name)
      "#{BASE_KEY}:#{identifier}:#{count_name}"
    end
  end
end
