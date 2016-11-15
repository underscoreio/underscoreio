module Jekyll
  module LookupFilters
    def lookup_all(input, coll, key_attr = 'id')
      coll = coll.values if coll.is_a?(Hash)
      coll.select do |item|
        if key_attr == 'id'
          item[key_attr] == input
        else
          item.data[key_attr] == input
        end
      end
    end

    def lookup_in(input, coll, key_attr = 'id')
      lookup_all(input, coll, key_attr).fetch(0, nil)
    end
  end
end

Liquid::Template.register_filter(Jekyll::LookupFilters)
