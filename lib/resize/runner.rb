module Resize

  class Runner < Boson::Runner
    [:fit, :fill].each do |command|
      class_eval do
        option :recursive, type: :boolean
        option :extentions, type: :array, split: "|", default: ["jpeg", "jpg", "gif", "png"]
        option :width, type: :numeric, required: true
        option :height, type: :numeric
        
        define_method command, ->(path, options = {}) do  
          Base.new(command, path, options).run
        end
      end 
    end
  end # Runner

end
