module Plan

  class Advice < Exception

    attr_reader :lines

    def initialize(*lines)
      @lines = lines
    end

    def message
      @lines.join("\n")
    end

  end

end
