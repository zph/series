require "series/version"
require 'hashie/mash'

module Series
  class Series < Delegator
    def initialize(obj)
      super                  # pass obj to Delegator constructor, required
      @delegate_sd_obj = normalize_input(obj)
    end

    def normalize_input(obj)
      Array(obj).each_with_object([]) do |o, object|
        object << case
                  when o.class == Hash
                    Hashie::Mash.new(o)
                  else
                    o
                  end
      end
    end
    def __getobj__
      @delegate_sd_obj # return object we are delegating to, required
    end

    def __setobj__(obj)
      @delegate_sd_obj = obj # change delegation object,
    end

    def argument_error?(hash)
      if hash.to_a.length > 1
        raise(ArgumentError, "One where allowed per call")
      end
    end

    def first(hash = nil)
      if hash
        where(hash).first
      else
        self[0]
      end
    end

    def where(hash)
      argument_error?(hash)

      k, v = *hash.to_a.first
      blk = lambda { |i| i.send(k) == v}
      Series.new(self.select(&blk))
    end

    def exclude(hash)
      argument_error?(hash)

      k, v = *hash.to_a.first
      blk = lambda { |i| i.send(k) == v}
      Series.new(self.reject(&blk))
    end

  end
end
