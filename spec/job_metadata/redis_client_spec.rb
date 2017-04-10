require 'spec_helper'

module JobMetadata
  describe RedisClient do
    let(:client) { RedisClient.new(JobMetadata.config.redis) }
    let(:set) { 'test_set' }
    let(:count) { 'test_count' }
    let(:ids) { (1..1000).to_a }

    before { JobMetadata.config.redis.flushall }

    describe '#add_to_set' do
      subject { client.add_to_set('test_set', ids) }

      it 'adds the items to the set' do
        subject
        expect(client.items_for_set(set).map(&:to_i).sort).to eq(ids.sort)
      end
    end

    describe '#items_for_set' do
      subject { client.items_for_set(set) }

      context 'with items in the set' do
        before { client.add_to_set(set, ids) }

        it 'returns the items from the set' do
          subject
          expect(subject.map(&:to_i).sort).to eq(ids.sort)
        end
      end
    end

    describe '#cardinality_of_set' do
      subject { client.cardinality_of_set(set) }

      context 'with items in the set' do
        before { client.add_to_set(set, ids) }

        it 'returns the number of items in the set' do
          expect(subject).to eq(ids.size)
        end
      end
    end

    describe '#remove_from_set' do
      subject { client.remove_from_set(set, ids - [1]) }

      context 'with items in the set' do
        before { client.add_to_set(set, ids) }

        it 'removes the argued items from the set' do
          subject
          expect(client.cardinality_of_set(set)).to eq(1)
        end
      end
    end

    describe '#increment_count_by' do
      it 'creates a count or increments it' do
        expect(client.increment_count_by(count, 1)).to eq(1)
        expect(client.increment_count_by(count, 1000)).to eq(1001)
      end
    end

    describe '#count' do
      subject { client.count(count) }

      context 'with a count created' do
        before { client.increment_count_by(count, 1000) }

        it 'returns the count' do
          expect(subject).to eq(1000)
        end
      end
    end

    describe '#remove_count' do
      subject { client.remove_count(count) }

      context 'with a count created' do
        before { client.increment_count_by(count, 1000) }

        it 'removes the count' do
          subject
          expect(client.count(count)).to eq(0)
        end
      end
    end
  end
end
