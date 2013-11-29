require 'singleton'

class BabyFace::Configuration
  include Singleton

  def self.data_dir=(data_dir)
    instance.data_dir = data_dir
  end

  def self.data_dir
    instance.data_dir
  end

  attr_accessor :data_dir
end
