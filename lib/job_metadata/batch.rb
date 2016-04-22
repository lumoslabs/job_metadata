module JobMetadata
  class Batch
    BASE_KEY = 'job_metadata_batch'.freeze

    include SetAccessors
    include CountAccessors

    attr_accessor :job_identifier, :index

    def initialize(job_identifier, index)
      @job_identifier = job_identifier
      @index = index
    end

    private

    def key_for_set(set_name)
      "#{BASE_KEY}:#{job_identifier}:#{index}:#{set_name}:set"
    end

    def key_for_count(set_name)
      "#{BASE_KEY}:#{job_identifier}:#{index}:#{set_name}:count"
    end
  end
end
