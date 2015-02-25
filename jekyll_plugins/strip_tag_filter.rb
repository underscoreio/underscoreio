module StripTagFilter
  def strip_tag(input, tag = "strike")
    input.sub( %r{<#{tag}>.*</#{tag}>}, '' )
  end
end

Liquid::Template.register_filter(StripTagFilter)
