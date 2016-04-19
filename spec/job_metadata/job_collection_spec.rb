require 'spec_helper'

module JobMetadata
  describe JobCollection do
    it_behaves_like 'it includes SetAccessors', JobCollection.new

    let(:job_collection) { JobCollection.new }

    before do
      JobMetadata.config.redis.flushall

      # fakeredis has a bug that causes this to not work unless we never go over the offset
      # https://github.com/guilleiguaran/fakeredis/pull/165
      999.times do |time|
        job_collection.new_job("test_job_#{time}")
      end
    end

    describe '#new_job' do
      subject { job_collection.new_job('test_job_id') }

      it 'returns a job' do
        expect(subject).to be_a(Job)
      end

      it "adds the job to the job_collection's jobs" do
        job = subject
        expect(job_collection.items_for_set(:jobs).to_a.last).to eq(job.identifier)
      end
    end

    describe '#all_jobs' do
      context 'with a job present' do
        let!(:job) { job_collection.new_job('test_job_id') }

        it 'returns a job object with the matching identifier' do
          expect(job_collection.all_jobs.last.identifier).to eq(job.identifier)
        end
      end
    end
  end
end
