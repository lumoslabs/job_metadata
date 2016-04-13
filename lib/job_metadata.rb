require "job_metadata/version"

module JobMetadata
  class << self
    def all_jobs
      JobCollection.new(client).all_jobs
    end

    def new_job(identifier)
      JobCollection.new(client).new_job(identifier)
    end

    def batch_for(options)
      raise ArgumentError unless [:job_id, :batch_index].all? { |key| options.keys.include?(key) }

      Batch.new(client, options[:job_id], options[:batch_index])
    end

    def tracker_for(options)
      raise ArgumentError unless [:job_id, :batch_index].all? { |key| options.keys.include?(key) }

      job = Job.new(client, options[:job_id])
      batch = Batch.new(client, options[:job_id], options[:batch_index])

      BatchTracker.new(
        batch: batch,
        job: job,
        error_callback: config.error_callback,
        ids_to_records: options[:ids_to_records],
        record_to_id: options[:record_to_id]
      )
    end

    def client
      RedisClient.new(config.redis)
    end

    def config
      @config ||= OpenStruct.new
    end
  end
end
