require "singleton"

module BabyFace
  class Configuration
    include Singleton

    attr_accessor :data_dir
  end
end
