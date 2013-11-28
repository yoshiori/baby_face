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
    scan(nil, self).flatten.join(" ")
  end

  def wakachi(text)
    text.split
  end
end
