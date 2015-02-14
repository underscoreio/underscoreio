# Backported from a later version of Jekyll/Liquid:
module DefaultFilter
  def default(input, default_value = "")
    is_blank = input.respond_to?(:empty?) ? input.empty? : !input
    is_blank ? default_value : input
  end
end

Liquid::Template.register_filter(DefaultFilter)
