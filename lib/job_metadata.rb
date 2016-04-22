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
      JobCollection.all_jobs
    end

    def new_job(job_name)
      job_identifier = generate_identifier(job_name)
      JobCollection.new_job(job_identifier)
    end

    def tracker_for(options)
      raise ArgumentError unless [:job_identifier, :batch_index].all? { |key| options.keys.include?(key) }

      job = Job.new(options[:job_identifier])
      batch = Batch.new(options[:job_identifier], options[:batch_index])

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

    private

    def generate_identifier(job_name)
      "#{job_name}:#{Time.now.utc.strftime('%Y-%m-%d_%H-%M-%S')}_#{rand.to_s[2..6]}"
    end
  end
end
