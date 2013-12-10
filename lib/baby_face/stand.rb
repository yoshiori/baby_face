require "baby_face/configuration"
require 'pstore'
require 'classifier'

class BabyFace::Stand
  def initialize(mod)
    @mod = mod
    @categories = mod.class.class_variable_get(:@@_categories)
    @categories.each do |category|
      self.class.class_eval do
        define_method("#{category}?") {
          bayes.classify(to_feature).gsub(" ", "_").downcase == category.to_s
        }

        define_method("train_#{category}") {
          bayes.train(category, to_feature)
        }
      end
    end
    @tokenizer = mod.class.class_variable_get(:@@_tokenizer)
  end

  def classifications
    bayes.classifications(to_feature)
  end

  def to_feature
    def scan(prefix, obj)
      obj.class.class_variable_get(:@@_features).map do |attr|
        short_key = obj.baby_face.send(:short_keys)[attr]
        _prefix = prefix.nil? ? short_key : "#{prefix}_#{short_key}"
        value = obj.send(attr)
        if value.is_a? BabyFace
          scan(_prefix, value)
        elsif value.is_a? Array
          value.map do |val|
            scan(_prefix, val)
          end
        elsif value.is_a? Hash
          _short_keys = BabyFace::Stand.short_keys(*value.keys)
          value.map do |key, val|
            _key = _short_keys[key]
            scan("#{_prefix}_#{_key}", val)
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

  def save
    bayes # Memoization (first access is in transaction)
    pstore.transaction do
      pstore[@mod.class.name] = bayes
      pstore.commit
    end
  end

  def self.short_keys(*attrs)
    Hash[attrs.sort.zip(
        attrs.sort.reduce([]) do |ary, attr|
          first_letter = attr.to_s.chars.first
          short_key = first_letter
          count = 1
          while ary.include? short_key
            count += 1
            short_key = "#{first_letter}#{count}"
          end
          ary << short_key
        end
    )]
  end

  private
  def short_keys
    if @mod.class.class_variable_defined?(:@@_short_keys)
      @mod.class.class_variable_get(:@@_short_keys)
    else
      @mod.class.class_variable_set(:@@_short_keys,
        BabyFace::Stand.short_keys(*@mod.class.class_variable_get(:@@_features)))
    end
  end

  def wakachi(text)
    @tokenizer ? @tokenizer.call(text) : text.split
  end

  def data_path
    if BabyFace.configuration.data_dir
      Pathname.new(BabyFace.configuration.data_dir).join("#{@mod.class.name.downcase}.babyface")
    else
      Pathname.new("#{@mod.class.name.downcase}.babyface")
    end
  end

  def pstore
    if @mod.class.class_variable_defined?(:@@_pstore)
      @mod.class.class_variable_get(:@@_pstore)
    else
      @mod.class.class_variable_set(:@@_pstore, PStore.new(data_path))
    end
  end

  def bayes
    if @mod.class.class_variable_defined?(:@@_bayes)
      @mod.class.class_variable_get(:@@_bayes)
    else
      @mod.class.class_variable_set(:@@_bayes,
        if data_path && data_path.exist?
          pstore.transaction(true) do
            pstore[@mod.class.name]
          end
        else
          ::Classifier::Bayes.new *@categories
        end
      )
    end
  end
end
