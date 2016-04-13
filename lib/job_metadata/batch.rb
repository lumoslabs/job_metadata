module JobMetadata
  class Batch
    BASE_KEY = 'batching_batch'

    include SetAccessors
    include CountAccessors

    attr_accessor :client, :job_identifier, :index

    def initialize(client, job_identifier, index)
      @client = client
      @job_identifier = job_identifier
      @index = index
    end

    private

    def key_for_set(set_name)
      "#{BASE_KEY}:#{job_identifier}:#{index}:#{set_name}"
    end
  end
end
