shared_examples 'it includes SetAccessors' do |object|
  let(:ids) { (1..1000).to_a }

  describe '#add_to_set' do
    it 'allows you to add items to the set' do
      expect(object.add_to_set(:test_set, ids)).to eq(true)
      expect(object.items_for_set(:test_set).map(&:to_i).sort).to eq(ids)
    end
  end

  describe '#cardinality_of_set' do
    context 'with items in the set' do
      before { object.add_to_set(:test_set, ids) }

      it 'returns the number of items in the set' do
        expect(object.cardinality_of_set(:test_set)).to eq(1000)
      end
    end
  end

  describe '#remove_from_set' do
    context 'with items in the set' do
      before { object.add_to_set(:test_set, ids) }

      it 'allows removal of items from the set' do
        object.remove_from_set(:test_set, [1,2])
        expect(object.cardinality_of_set(:test_set)).to eq(998)
      end
    end
  end

  describe '#items_for_set' do
    context 'with items in the set' do
      before { object.add_to_set(:test_set, ids) }

      it 'returns the items in the set' do
        expect(object.items_for_set(:test_set).map(&:to_i).sort).to eq(ids)
      end
    end
  end

  describe '#remove_set' do
    context 'with items in the set' do
      before { object.add_to_set(:test_set, ids) }

      it 'removes all the items in the set' do
        object.remove_set(:test_set)
        expect(object.items_for_set(:test_set)).to eq([])
      end
    end
  end
end
