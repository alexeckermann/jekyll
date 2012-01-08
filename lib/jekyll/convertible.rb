require 'set'

# Convertible provides methods for converting a pagelike item
# from a certain type of markup into actual content
#
# Requires
#   self.site -> Jekyll::Site
#   self.content
#   self.content=
#   self.data=
#   self.ext=
#   self.output=
module Jekyll
  module Convertible
    # Returns the contents as a String.
    def to_s
      self.content || ''
    end

    # Read the YAML frontmatter.
    #
    # base - The String path to the dir containing the file.
    # name - The String filename of the file.
    #
    # Returns nothing.
    def read_yaml(base, name)
      self.content = File.read(File.join(base, name))

      if self.content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        self.content = $POSTMATCH

        begin
          self.data = YAML.load($1)
        rescue => e
          puts "YAML Exception reading #{name}: #{e.message}"
        end
      end
      
      self.data ||= {}
    end

    # Transform the contents based on the content type.
    #
    # Returns nothing.
    def transform #(scope = nil, locals = {})
      # locals = { 'page' => self.data }.deep_merge(locals)
      self.content = converter.format(self.content)
    end

    # Determine the extension depending on content_type.
    #
    # Returns the String extension for the output file.
    #   e.g. ".html" for an HTML output file.
    def output_ext
      converter.output_ext(self.ext)
    end

    # Determine which converter to use based on this convertible's
    # extension.
    #
    # Returns the Converter instance.
    def converter
      @converter ||= self.site.converters.find { |c| c.matches(self.ext) }
    end

    # Add any necessary layouts to this convertible document.
    #
    # payload - The site payload Hash.
    # layouts - A Hash of {"name" => "layout"}.
    #
    # Returns nothing.
    def do_layout(layout_payload, layouts)
      
      self.output = self.render_layout([Jekyll::Filters], layout_payload, layouts)
      
    end
    
    # Recursively render the layout with the appropriate ambiguous converter
    #
    # layouts - The Jekyll::Layout objects we are operating on
    # scope - All out lovely filters and nick-nacks, as an Array
    # locals - The variables accessible to the layout
    # block - any child content we can render
    #
    # Returns nothing, does operate a recursive loop
    def render_layout(scope = [], locals = {}, layouts = {}, &block)
      
      if layouts.include?(self.data["layout"])
        # Loop into the parent layout
        layout = layouts[self.data["layout"]]
        layouts.delete(layout.data["layout"])
        
        return layout.render_layout(scope, locals, layouts) do
          converter.convert(self.content, scope, locals)
        end
      end

      # Render this layout, it has no parent!
      self.converter.convert(self.content, scope, locals, &block)
    end
    
  end
end
