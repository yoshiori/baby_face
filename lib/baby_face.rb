require "baby_face/stand"
require "baby_face/configuration"
require "baby_face/version"

module BabyFace

  def self.configuration
    @configuration ||= Configuration.instance
  end

  def BabyFace.included(mod)
    mod.define_singleton_method(
      :baby_face_for,
      lambda { |config|
        features = *config[:features]
        categories = *config[:categories]
        mod.class_variable_set(:@@_features, features)
        mod.class_variable_set(:@@_categories, categories)
        mod.class_variable_set(:@@_tokenizer, config[:tokenizer])
      }
    )
  end

  def baby_face
    @_baby_face ||= BabyFace::Stand.new(self)
  end
end
