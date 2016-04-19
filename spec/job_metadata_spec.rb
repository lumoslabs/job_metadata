require 'spec_helper'

describe JobMetadata do
  it 'has a version number' do
    expect(JobMetadata::VERSION).not_to be nil
  end
end
