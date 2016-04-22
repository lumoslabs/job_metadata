require 'spec_helper'

module JobMetadata
  describe BatchTracker do
    let(:job) { JobMetadata.new_job('test_job') }
    let(:ids) { (1..1000).to_a }
    let(:batch) { job.new_batch_for_items(ids) }
    let(:batch_index) { batch.index }
    let(:ids_to_records_conversion) { ->(ids) { ids.map { |id| { id: id, other_value: 'test' } } } }
    let(:record_to_id_conversion) { ->(record) { record[:id] } }
    let(:rollbar_double) { double('rollbar') }
    let(:error_callback) { ->(*args) { rollbar_double.error(*args) } }
    let(:tracker) do
      BatchTracker.new(
        batch: batch,
        job: job,
        error_callback: error_callback
      )
    end
    let(:bogus_model) { double(bogus_func: nil) }
    let(:error) { false }
    let(:error_id) { '2' }

    describe '#each_record' do
      def test_func(record)
        record = record_to_id_conversion.call(record) if record.is_a?(Hash)

        bogus_model.bogus_func
        if error
          raise error if record == error_id
        end
      end

      shared_examples_for 'an each_record method' do
        subject { tracker.each_record { |id| test_func(id) } }

        context 'when there are no conversions between ids and records' do
          it 'yields each id' do
            expect(bogus_model).to receive(:bogus_func).exactly(ids.size).times
            subject
          end
        end

        it 'removes the batch and all the ids in the batch' do
          index = batch_index
          expect do
            subject
          end.to change { job.cardinality_of_set(:batches) }.by(-1)
          expect(batch.cardinality_of_set(:pending)).to eq(0)
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end

        context 'when the block throws a StandardError' do
          let(:error) { StandardError.new }
          let(:rollbar_uuid) { 'rollbar-u-uid' }

          before do
            allow(rollbar_double).to receive(:error)
            tracker # generates batch for change tests
          end

          it 'still iterates through all the ids in the batch' do
            expect(bogus_model).to receive(:bogus_func).exactly(ids.size).times
            subject
          end

          it 'still removes all the ids from the batch' do
            expect do
              subject
            end.to change { job.cardinality_of_set(:batches) }.by(-1)
            expect(batch.cardinality_of_set(:pending)).to eq(0)
          end

          it 'adds the errored id and rollbar uuid to the error set' do
            subject
            expect(job.items_for_set(:errored).first).to eq(error_id)
          end

          it 'sends a rollbar_double alert with the the id' do
            expect(rollbar_double).to receive(:error).with(error, { id: error_id })
            begin
              subject
            rescue
            end
          end

          it 'returns false' do
            expect(subject).to be_falsey
          end
        end

        context 'when the block throws an Exception' do
          let(:error) { Exception.new('Test Exception') }
          let(:rollbar_uuid) { 'rollbar-u-uid' }

          before do
            allow(rollbar_double).to receive(:error) { { uuid: rollbar_uuid } }
            tracker # generates batch for change tests
          end

          it 'does not iterate through all the ids in the batch' do
            called_count = 0
            allow(bogus_model).to receive(:bogus_func) { called_count += 1 }
            begin
              subject
            rescue RSpec::Mocks::MockExpectationError
              raise $!
            rescue Exception
            end
            expect(called_count).to be < ids.size
          end

          it 'reraises the exception' do
            expect { subject }.to raise_error(Exception, 'Test Exception')
          end

          it 'still removes all the ids from the batch' do
            expect do
              begin
                subject
              rescue Exception
              end
            end.to change { job.cardinality_of_set(:batches) }.by(-1)
            expect(batch.cardinality_of_set(:pending)).to eq(0)
          end

          it 'adds all the ids to the error set' do
            begin
              subject
            rescue Exception
            end
            expect(job.items_for_set(:errored).to_a.map(&:to_i).sort).to eq(ids)
          end

          it 'sends a rollbar_double alert with the the id' do
            expect(rollbar_double).to receive(:error) do |exception, extra_hash|
              expect(extra_hash[:id]).to eq(3)
            end

            begin
              subject
            rescue RSpec::Mocks::MockExpectationError
              raise $!
            rescue Exception
            end
          end
        end
      end

      context 'when no conversions between ids and records' do
        it_behaves_like 'an each_record method'
      end

      context 'when there are conversions between id and records' do
        let(:tracker) do
          BatchTracker.new(
            batch: batch,
            job: job,
            error_callback: error_callback,
            ids_to_records: ids_to_records_conversion,
            record_to_id: record_to_id_conversion
          )
        end

        it_behaves_like 'an each_record method'
      end
    end
  end
end
