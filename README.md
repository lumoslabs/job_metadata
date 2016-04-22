# JobMetadata

Distributed Batched Job Metadata Management

This gem is intended to be used alongside a job queuing library. It can be used to provide context for jobs with many batches.
It allows batches or jobs to look up data they need in order to perform in a centralized store, and to report outcomes to the centralized store.

Currently, it is intended to be used with Redis as the centralized store.

## Usage

To start off a new job, just provide a job name.
```ruby
job = JobMetadata.new_job('my_very_special_import_job')
```

Batches can be created by calling `job.new_batch_for_items`. Each batch then gets a `batch_index`.
For example, you might use this in batching job that separates a large job into many batches:
```ruby
class BatchingJob
  def perform
    job = JobMetadata.new_job('my_very_special_import_job')

    very_large_collection.each_slice(1000) do |slice|
      batch = job.new_batch_for_items(slice)
      Resque.enqueue(ImportBatchJob, job_identifier: job.identifier, batch_index: batch.index)
    end
  end
end
```

Using the `job_identifier` and `batch_index`, batches can then access the data and report on outcomes.
```ruby
class ImportBatchJob
  def perform(options)
    batch = JobMetadata::Batch.new(options[:job_identifier], options[:batch_index])

    batch.items_for_set(:pending).each do |item_id|
      get_item_using_id(item_id)
    end

    batch.remove_set(:pending)
  end
end
```

You can also use the `BatchTracker`, which handles reporting on the items automatically. Done this way the tracker removes batches when they are done and reports any errored or skipped ids. It also reports a count of the processed ids. All this reporting happens when the batch is over.

```ruby
class ImportBatchJob
  def perform(options)
    tracker = JobMetadata.tracker_for(job_identifier: options[:job_identifier], batch_index: options[:batch_index])

    tracker.each_record do |id|
      widget = Widget.find(id)

      next :skipped if widget.already_imported?

      widget.import!
    end
  end
end
```

Finally, if you want to do a lookup for all items in a batch with a single query, etc, the `BatchTracker` accepts a lambda for ids to records and single record back to id (for reporting).

```ruby
class ImportBatchJob
  def perform(options)
    ids_to_records = ->(ids) { Widget.where('id IN (?)', ids) }
    record_to_id = ->(record) { record.id }

    tracker = JobMetadata.tracker_for(
      job_identifier: options[:job_identifier],
      batch_index: options[:batch_index],
      ids_to_records: ids_to_records,
      record_to_id: record_to_id
    )

    tracker.each_record do |widget|
      next :skipped if widget.already_imported?

      widget.import!
    end
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'job_metadata'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install job_metadata

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/job_metadata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
