require 'liquid'

module Jekyll
  module BaseIdFilter
    def baseid(id)
      id.split('/').last
    end
  end
end

Liquid::Template.register_filter(Jekyll::BaseIdFilter)