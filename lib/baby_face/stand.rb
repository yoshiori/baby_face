class BabyFace::Stand
  def initialize(mod)
    @mod = mod
    @categories = mod.class.class_variable_get(:@@_categories)
    @categories.each do |category|
      self.class.class_eval do
        define_method("#{category}?") {
          bayes.classify(to_feature).downcase == category.to_s
        }

        define_method("train_#{category}") {
          bayes.train(category, to_feature)
        }
      end
    end
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

  private
  def bayes
    require 'classifier'
    @@bayes ||= ::Classifier::Bayes.new *@categories
  end
end
