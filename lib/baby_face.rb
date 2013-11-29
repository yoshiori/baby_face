require "baby_face/version"

module BabyFace

  def BabyFace.included(mod)
    mod.define_singleton_method(
      :acts_as_feature,
      lambda { |*args|
        mod.class_variable_set(:@@_features, args)
      }
    )
  end

  class Stand
    def initialize(mod)
      @mod = mod
    end

    def to_feature
      def scan(prefix, obj)
        obj.class.class_variable_get(:@@_features).map do |attr|
          _prefix = prefix.nil? ? attr : "#{prefix}_#{attr}"
          value = obj.send(attr)
          case value
          when BabyFace
            scan(_prefix, value)
          when Array
            value.map do |val|
              scan(_prefix, val)
            end
          when Hash
            value.map do |key, val|
              scan("#{_prefix}_#{key}", val)
            end
          else
            wakachi(value.to_s).map do |text|
              "#{_prefix}_#{text}"
            end
          end
        end
      end
      scan(nil, @mod).flatten.join(" ")
    end

    def wakachi(text)
      text.split
    end

    def train(type)
      bayes.train(type, to_feature)
    end

    def maybe
      bayes.classify(to_feature)
    end

    private
    def bayes
      require 'classifier'
      @@bayes ||= ::Classifier::Bayes.new 'Light', 'Dark'
    end
  end

  def babyface
    @babyface ||= BabyFace::Stand.new(self)
  end
end
