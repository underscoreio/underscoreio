# encoding: utf-8

module Jekyll
  class CurrenciesTag < Liquid::Tag
    @@currencyRegex = /([£$€])\s*([\d,']+)/
    @@currencyIds = Hash[ '£' => 'gbp', '$' => 'usd', '€' => 'eur' ]

    def initialize(tag_name, markup, tokens)
      super
      @prices = Hash[ markup.scan(@@currencyRegex).map { |match| [ match[0], match[1] ] } ]
    end

    def render(context)
      ans = "<span class=\"currencies currencies-nojs\">"
      @prices.each do |currency, value|
        currencyId = @@currencyIds[currency]
        ans << "<span class=\"currency currency-#{currencyId}\">#{currency}#{value}</span>"
      end
      ans << "</span>"
    end
  end
end

Liquid::Template.register_tag('currencies', Jekyll::CurrenciesTag)
