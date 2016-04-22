module JobMetadata
  class Job
    include SetAccessors
    include CountAccessors

    attr_accessor :identifier

    BASE_KEY = 'job_metadata_job'.freeze

    def initialize(identifier)
      @identifier = identifier
    end

    def new_batch_for_items(items)
      batch_index = increment_count_by(:batches, 1)
      add_to_set(:batches, batch_index)
      batch = Batch.new(identifier, batch_index)
      batch.add_to_set(:pending, items)
      batch
    end

    def remove_batch(batch_index)
      remove_from_set(:batches, batch_index)
    end

    private

    def key_for_set(set_name)
      "#{BASE_KEY}:#{identifier}:#{set_name}:set"
    end

    def key_for_count(count_name)
      "#{BASE_KEY}:#{identifier}:#{count_name}:count"
    end
  end
end
