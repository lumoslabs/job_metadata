require 'job_metadata/set_accessors'
require 'job_metadata/count_accessors'
require 'ostruct'
require 'job_metadata/batch'
require 'job_metadata/batch_tracker'
require 'job_metadata/job'
require 'job_metadata/job_collection'
require 'job_metadata/redis_client'
require 'job_metadata/version'

module JobMetadata
  class << self
    def all_jobs
      JobCollection.new.all_jobs
    end

    def new_job(identifier)
      JobCollection.new.new_job(identifier)
    end

    def tracker_for(options)
      raise ArgumentError unless [:job_id, :batch_index].all? { |key| options.keys.include?(key) }

      job = Job.new(options[:job_id])
      batch = Batch.new(options[:job_id], options[:batch_index])

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
      raise 'JobMetadata must be configured' unless defined?(@config)
      @config
    end

    def configure(&block)
      configurator = OpenStruct.new
      yield(configurator)
      @config = configurator
    end
  end
end
