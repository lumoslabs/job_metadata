require 'spec_helper'

module JobMetadata
  describe Batch do
    it_behaves_like 'it includes SetAccessors', Batch.new('bogus_job_id', 1)

    it_behaves_like 'it includes CountAccessors', Batch.new('bogus_job_id', 1)
  end
end
