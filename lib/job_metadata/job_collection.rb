module JobMetadata
  class JobCollection
    extend SetAccessors
    class << self

      BASE_KEY = 'job_metadata_job_collection'.freeze

      def new_job(identifier)
        add_to_set(:jobs, identifier)
        Job.new(identifier)
      end

      def all_jobs
        items_for_set(:jobs).map { |job_identifier| Job.new(job_identifier) }
      end

      private

      def key_for_set(set_name)
        "#{BASE_KEY}:#{set_name}:set"
      end
    end
  end
end
