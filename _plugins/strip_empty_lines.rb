module Jekyll
  class StripEmptyLinesTag < Liquid::Block
    REGEXP = /(\n\s*\n)+/

    def render(context)
      super.gsub(REGEXP, "\n")
    end
  end
end

Liquid::Template.register_tag('stripemptylines', Jekyll::StripEmptyLinesTag)

