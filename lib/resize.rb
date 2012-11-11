require "boson/runner"
require "rmagick"

module Resize
  
  require "resize/base"
  require "resize/runner"

  class << self
    def start
      Runner.start
    end
  end
  
end # Resize

# RMagick monkey patch because I'm unable to subclass Image
# as the `read` method return explicitly Image instance 
# from RMagick module.
module Magick
  module Interpolate
    INTERPOLATIONS = ["basename", "extension", "width", "height", "columns", "rows"]

    def self.included(klass)
      klass.instance_eval do
        alias_method :width, :columns
        alias_method :height, :rows
      end
    end

    def basename
      File.basename(filename, ".*")
    end

    def extension
      File.extname(filename)[1..-1]
    end
    
    def dirname
      File.dirname(filename)
    end

    def interpolate(format)
      INTERPOLATIONS.inject(format) do |result, interpolation|
        value = send(interpolation).to_s
        result.gsub(/:#{interpolation}/, value)
      end.gsub(" ", "_")
    end
  end

  class Image
    include Interpolate

    def write_with_format(format)
      format = interpolate(format)
      write("#{dirname}/#{format}")
    end
  end
end
