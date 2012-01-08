module Jekyll
  
  class LiquidConverter < Converter
    safe true

    def matches(ext)
      ext =~ /html|liquid/i
    end

    def output_ext(ext)
      ".html"
    end
    
  end

end
