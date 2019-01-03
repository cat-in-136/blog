# frozen_string_literal: true
module Jekyll
  class RenderOnceUseCacheTag < Liquid::Block
    @@cache = {}

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      @@cache[@text] = super unless @@cache.include?(@text)
      @@cache[@text]
    end
  end
end

Liquid::Template.register_tag('renderonceusecache', Jekyll::RenderOnceUseCacheTag)

