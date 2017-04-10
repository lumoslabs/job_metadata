module JobMetadata
  class BatchTracker
    attr_accessor :batch, :job, :error_callback

    class BatchException < StandardError; end

    def initialize(options)
      @batch = options.fetch(:batch)
      @job = options.fetch(:job)
      @error_callback = options.fetch(:error_callback)
      @ids_to_records = options.fetch(:ids_to_records, nil)
      @record_to_id = options.fetch(:record_to_id, nil)
      @errored_ids = []
      @skipped_ids = []
      @processed_ids = []
    end

    def each_record
      begin
        records.each do |record|
          begin
            check_and_handle_result(record, yield(record))
          rescue StandardError => se
            @errored_ids << record_to_id(record)
            error_callback.call(se, id: record_to_id(record))
            job.add_to_set(:errored, record_to_id(record))
          rescue Exception => ex
            @errored_ids.concat(batch.items_for_set(:pending).to_a)
            error_callback.call(ex, id: record_to_id(record))
            job.add_to_set(:errored, batch.items_for_set(:pending))
            raise ex
          end
        end

      ensure
        report_results

        if @errored_ids.size > 0
          error_callback.call('Batch contained errors', ids: @errored_ids, batch_index: batch.index)
        end
      end

      @errored_ids.size > 0 ? false : true
    end

    private

    def report_results
      job.add_to_set(:skipped, @skipped_ids) unless @skipped_ids.empty?
      job.increment_count_by(:processed, @processed_ids.size)
      batch.remove_set(:pending)
      job.remove_batch(batch.index)
    end

    def check_and_handle_result(record, result)
      if result && result == :skipped
        @skipped_ids << record_to_id(record)
      else
        @processed_ids << record_to_id(record)
      end
    end

    def records
      begin
        ids = batch.items_for_set(:pending)
        @ids_to_records ? @ids_to_records.call(ids) : ids
      rescue StandardError => se
        error_callback.call(se, ids: ids)
        job.add_to_set(:errored, batch.items_for_set(:pending))
        raise se
      end
    end

    def record_to_id(record)
      begin
        @record_to_id ? @record_to_id.call(record) : record
      rescue StandardError => se
        error_callback.call(se, record: record)
        raise se
      end
    end
  end
end
