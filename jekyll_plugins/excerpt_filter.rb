module ExcerptFilter
  @@defaultSeparator = Jekyll.configuration({})['excerpt_separator']

  def excerpt(input, separator = @@defaultSeparator)
    if input.include? separator
      input.split(separator).first
    else
      input
    end
  end
end

Liquid::Template.register_filter(ExcerptFilter)
