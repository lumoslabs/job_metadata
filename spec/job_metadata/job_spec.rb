require 'spec_helper'

module JobMetadata
  describe Job do
    it_behaves_like 'it includes SetAccessors', Job.new('bogus_job_id')

    it_behaves_like 'it includes CountAccessors', Job.new('bogus_job_id')

    let(:job) { Job.new('bogus_job_id') }
    let(:ids) { (1..1000).to_a }

    before { JobMetadata.config.redis.flushall }

    describe '#new_batch_for_items' do
      subject { job.new_batch_for_items(ids) }

      it 'returns a batch' do
        expect(subject).to be_a(Batch)
      end

      it 'adds the ids to the pending set of the batch' do
        expect(subject.items_for_set(:pending).map(&:to_i)).to eq(ids)
      end

      it "adds the batch to the job's batches" do
        batch = subject
        expect(job.items_for_set(:batches).first.to_i).to eq(batch.index)
      end
    end

    describe '#remove_batch' do
      context 'with a batch present' do
        let!(:batch) { job.new_batch_for_items(ids) }

        it "removes the batch from the job's batches" do
          job.remove_batch(batch.index)
          expect(job.items_for_set(:batches)).to be_empty
        end
      end
    end
  end
end
