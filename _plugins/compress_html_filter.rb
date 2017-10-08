# frozen_string_literal: true
module Jekyll
  class CompressHTMLTag < Liquid::Block
    REGEXP = %r{
      # http://stackoverflow.com/questions/5312349/minifying-final-html-output-using-regular-expressions-with-codeigniter#5324014
      # 
      # Collapse whitespace everywhere but in blacklisted elements.
      (?>             # Match all whitespaces other than single space.
        [^\S ]\s*     # Either one [\t\r\n\f\v] and zero or more ws,
      | \s{2,}        # or two or more consecutive-any-whitespace.
      ) # Note: The remaining regex consumes no text at all...
      (?=             # Ensure we are not in a blacklist tag.
        [^<]*+        # Either zero or more non-"<" {normal*}
        (?:           # Begin {(special normal*)*} construct
          <           # or a < starting a non-blacklist tag.
          (?!/?(?:textarea|pre|script)\b)
          [^<]*+      # more non-"<" {normal*}
        )*+           # Finish "unrolling-the-loop"
        (?:           # Begin alternation group.
          <           # Either a blacklist start tag.
          (?>textarea|pre|script)\b
        | \z          # or end of file.
        )             # End alternation group.
      )  # If we made it here, we are not in a blacklist tag.
    }mix
  
    def render(context)
      super.gsub(REGEXP, "\n")
    end
  end
end

Liquid::Template.register_tag('compresshtml', Jekyll::CompressHTMLTag)

