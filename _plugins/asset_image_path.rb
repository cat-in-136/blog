# Title: Simple Image Path URL expansion tag
# Author: @cat_in_136
#
# Copyright (C) 2014 @cat_in_136
#
# Avarilable under MIT License <http://opensource.org/licenses/mit-license.php>
#

require 'image_size'
require 'rexml/document'

module Jekyll
  class AssetImagePathTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @filename = text.strip
    end

    def render(context)
      raise "File not specified" if @filename.empty?

      AssetImagePathTag::convert_path(@filename, context)
    end

    def self.convert_path(filename, context)
      site = context.environments.first["site"]
      "#{site['baseurl']}/images/#{filename}"
    end
  end

  class AssetImageSizeTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @filename = text.strip
    end

    def render(context)
      raise "File not specified" if @filename.empty?

      width, height = AssetImageSizeTag::get_size(@filename)
      unless (width.nil? || height.nil?)
        " width=\"#{width}\" height=\"#{height}\" "
      else
        ''
      end
    end

    def self.get_size(filename)
      width = height = nil
      path = File.expand_path("../images/#{filename}", File.basename(__FILE__))
      raise "File not found: '#{filename}'" unless File.exist?(path)
      if (File.extname(path).downcase == '.svg')
        File.open(path, 'r') do |f|
          f.flock(File::LOCK_SH)
          doc = REXML::Document.new(f)
          width  = doc.root.attribute(:width).value.to_f.round  # "/*/@width"
          height = doc.root.attribute(:height).value.to_f.round # "/*/@height"
        end
      else
        File.open(path, 'r') do |f|
          f.flock(File::LOCK_SH)
          imgsize = ImageSize.new(f)
          width = imgsize.get_width
          height = imgsize.get_height
        end
      end

      [width, height]
    end
  end

  class AssetImageTagTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      attributes = ['class', 'src', 'width', 'height', 'title']
      if markup.strip =~ /((?<class>\S+|["'][^"']+["'])\s+)?(?<src>(?:https?:\/\/|\/|\S+\/)?\S+\.\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
        @img = attributes.reduce({}) { |img, attr| img[attr] = $~[attr].strip if $~[attr]; img }
        if /\A(?<quotetitle>"|')(?<title>[^"']+)?(\k<quotetitle>)\s+(?<quotealt>"|')(?<alt>[^"']+)?(\k<quotealt>)\Z/ =~ @img['title']
          @img['title'], @img['alt'] = $~['title'], $~['alt']
        elsif /\A(?<quote>"|')(?<titlealt>[^"']+)(\k<quote>)\Z/ =~ @img['title']
          @img['title'], @img['alt'] = $~['titlealt'], $~['titlealt']
        else
          @img['alt'] = @img['title'] if @img['title']
        end
        @img['class'].gsub!(/"'/, '') if @img['class']
      else
        raise "Wrong argument for #{tag_name}: #{markup}"
      end
      super
    end

    def render(context)
      if @img
        if @img['width'].nil? || @img['height'].nil?
          width, height = AssetImageSizeTag.get_size(@img['src'])
          unless (width.nil? || height.nil?)
            @img['width'] = width.to_s
            @img['height'] = height.to_s
          end
        end

        # srcset
        if @img['src'] =~ /\.jpg$/
          srcsets = []
          (1..9).each do |ratio|
            file_at_x = @img['src'].sub(/\.jpg$/, "@#{ratio}x.jpg")
            if File.exist?(File.expand_path("../images/#{file_at_x}", File.basename(__FILE__)))
              srcsets << "#{AssetImagePathTag.convert_path(file_at_x, context)} #{ratio}x"
            end
          end
          @img['srcset'] = srcsets.join(', ') if srcsets.length > 0
        end

        @img['src'] = AssetImagePathTag.convert_path(@img['src'], context)

        "<img #{@img.collect {|k,v| "#{k}=\"#{CGI.escape_html(v)}\"" if v}.join(" ")} />"
      end
    end
  end

  class AssetImageObjectTagTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      attributes = ['class', 'src', 'width', 'height', 'title']
      if markup.strip =~ /((?<class>\S+|["'][^"']+["'])\s+)?(?<src>(?:https?:\/\/|\/|\S+\/)?\S+\.\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
        @img = attributes.reduce({}) { |img, attr| img[attr] = $~[attr].strip if $~[attr]; img }
        if /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/ =~ @img['title']
          @img['title'] = title
          @img['alt'] = alt
        else
          @img['alt'] = @img['title'].gsub!(/"/, '&#34;') if @img['title']
        end
        @img['class'].gsub!(/"/, '') if @img['class']
      else
        raise "Wrong argument for #{tag_name}: #{markup}"
      end
      super
    end

    def render(context)
      if @img
        if @img['width'].nil? || @img['height'].nil?
          width, height = AssetImageSizeTag.get_size(@img['src'])
          unless (width.nil? || height.nil?)
            @img['width'] = width.to_s
            @img['height'] = height.to_s
          end
        end

        @img['data'] = AssetImagePathTag.convert_path(@img.delete('src'), context)
        alt = @img.delete('alt')

        "<object #{@img.collect {|k,v| "#{k}=\"#{CGI.escape_html(v)}\"" if v}.join(" ")}>#{alt}</object>"
      end
    end
  end
end

Liquid::Template.register_tag('asset_image_path', Jekyll::AssetImagePathTag)
Liquid::Template.register_tag('asset_image_size', Jekyll::AssetImageSizeTag)
Liquid::Template.register_tag('asset_image_tag', Jekyll::AssetImageTagTag)
Liquid::Template.register_tag('asset_image_object_tag', Jekyll::AssetImageObjectTagTag)

# vim: filetype=ruby fileencoding=UTF-8 shiftwidth=2 tabstop=2 autoindent expandtab
