require 'baby_face'

describe BabyFace do
  class Hoge
    include BabyFace
  end


  it { Hoge.new.should_not be_nil }
end
