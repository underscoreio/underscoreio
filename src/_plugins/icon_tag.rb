# encoding: utf-8

module Jekyll
  class IconTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @icon_id = markup
    end

    def render(context)
      "<span class=\"icon-uio-#{@icon_id}\"></span>"
    end
  end
end

Liquid::Template.register_tag('icon', Jekyll::IconTag)
