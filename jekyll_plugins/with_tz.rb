module WithTzFilter
  def with_tz(input, tz = '')
    "#{input} #{tz}"
  end
end

Liquid::Template.register_filter(WithTzFilter)
