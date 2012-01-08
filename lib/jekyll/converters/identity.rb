module Jekyll

  class IdentityConverter < Converter
    safe true

    priority :lowest

    def matches(ext)
      true
    end

    def output_ext(ext)
      ext
    end

  end

end
