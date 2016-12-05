module Jekyll
  module ComparisonFilters
    def where_future(input, property)
      return input unless input.is_a?(Enumerable)
      input = input.values if input.is_a?(Hash)
      input.select do |object|
        time1 = ensure_time(item_property(object, property))
        time2 = Time.now
        time1 > time2
      end
    end

    def where_past(input, property)
      return input unless input.is_a?(Enumerable)
      input = input.values if input.is_a?(Hash)
      input.select do |object|
        time1 = ensure_time(item_property(object, property))
        time2 = Time.now
        time1 <= time2
      end
    end

    def ensure_time(input)
      if input.is_a? Time
        input
      else
        Time.parse(input.to_s)
      end
    end

    def item_property(item, property)
      if item.respond_to?(:to_liquid)
        item.to_liquid[property.to_s]
      elsif item.respond_to?(:data)
        item.data[property.to_s]
      else
        item[property.to_s]
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::ComparisonFilters)
