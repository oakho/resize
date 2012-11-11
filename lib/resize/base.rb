module Resize

  class Error < StandardError; end

  class Base
    
    attr_reader :type, :images, :recursive, :extentions, :args

    def initialize(type, path, options = {})
      @type       = type
      @recursive  = options.delete(:recursive)
      @extentions = options.delete(:extentions).join("|")
      @images     = images_collection(path)
      @args       = options.values
    end
    
    # Get a collection of image path that match given extensions
    def images_collection(path)
      images_collection = if recursive then Dir.glob("#{path}/**/*") else Dir.glob("#{path}/*") end
      images_collection.select { |i| i =~ /.+\.#{extentions}/i }
    end

    def resize_method
      case type
      when :fill    then :resize_to_fill!
      when :fit     then :resize_to_fit!
      when :default then :resize!
      end
    end

    def run
      STDOUT.puts "No images to resize" if images.nil?

      images.each do |image|
        image = Magick::Image.read(image).first

        dir = File.dirname(image.filename) + "/resized"
        FileUtils.mkdir_p(dir) unless File.directory?(dir)

        image.send(resize_method, *args)
        image.write_with_format("resized/:width_x_:height_:basename.:extension")

        STDOUT.puts image.basename

        image.destroy!
      end

      STDOUT.puts "Gratz! All images were resized." unless images.nil?
    end

  end # Base
  
end
