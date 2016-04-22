shared_examples 'it includes CountAccessors' do |object|
  let(:count) { 1000 }

  describe '#increment_count_by' do
    it 'creates a count or increments it' do
      expect(object.increment_count_by(:test_count, 1)).to eq(1)
      expect(object.increment_count_by(:test_count, 1000)).to eq(1001)
    end
  end

  describe '#count' do
    context 'with a count created' do
      before { object.increment_count_by(:test_count_2, 1000) }

      it 'returns the count' do
        expect(object.count(:test_count_2)).to eq(1000)
      end
    end
  end

  describe '#remove_count' do
    context 'with a count created' do
      before { object.increment_count_by(:test_count_3, 1000) }

      it 'removes the count' do
        object.remove_count(:test_count_3)
        expect(object.count(:test_count_3)).to eq(0)
      end
    end
  end
end
