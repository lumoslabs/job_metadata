module JobMetadata
  class RedisClient
    attr_accessor :redis

    BATCH_ENUMERATOR_SIZE = 1000
    REDIS_EXPIRY = 2_592_000 # 30 days

    def initialize(redis)
      @redis = redis
    end

    def add_to_set(set_name, items)
      redis.sadd(set_name, items)
      redis.expire(set_name, REDIS_EXPIRY)
    end

    def items_for_set(set_name)
      return [] if redis.scard(set_name).zero?

      Enumerator.new do |yielder|
        current_batch = 0
        records = get_batched_set_members(set_name, current_batch)

        until records.empty?
          records.each { |record| yielder.yield(record) }

          current_batch += 1
          records = get_batched_set_members(set_name, current_batch)
        end
      end
    end

    def cardinality_of_set(set_name)
      redis.scard(set_name)
    end

    def remove_from_set(set_name, items)
      redis.srem(set_name, items)
    end

    def remove_set(set_name)
      redis.del(set_name)
    end

    def increment_count_by(count_name, amount)
      counter = redis.incrby(count_name, amount)
      redis.expire(count_name, REDIS_EXPIRY)
      counter
    end

    def count(count_name)
      redis.get(count_name).to_i || 0
    end

    def remove_count(count_name)
      redis.del(count_name)
    end

    private

    def get_batched_set_members(set_name, batch_number)
      redis.sort(
        set_name,
        by: 'nosort',
        limit: [batch_number*BATCH_ENUMERATOR_SIZE, BATCH_ENUMERATOR_SIZE]
      )
    end
  end
end
