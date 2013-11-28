require 'baby_face'

describe BabyFace do

  describe "#to_feature" do
    subject { target.to_feature }

    class Hoge
      include BabyFace
      attr_accessor :title, :name
      acts_as_feature :title, :name

      def initialize(title: "Revenge of the Sith", name: "Anakin Skywalker")
        @title = title
        @name = name
      end
    end

    class Bar
      include BabyFace
      attr_accessor :attr1, :attr2
      acts_as_feature :attr1, :attr2

      def initialize(attr1: "foo", attr2: "bar")
        @attr1 = attr1
        @attr2 = attr2
      end
    end

    context "simple object" do
      let(:target) { Hoge.new }

      it { should eq "title_Revenge title_of title_the title_Sith name_Anakin name_Skywalker" }
    end

    context "nested object" do
      let(:target) { Hoge.new(name: Bar.new) }

      it { should eq "title_Revenge title_of title_the title_Sith name_attr1_foo name_attr2_bar" }
    end

    context "nested array" do
      let(:target) { Hoge.new(name: [Bar.new, Bar.new]) }

      it { should eq "title_Revenge title_of title_the title_Sith name_attr1_foo name_attr2_bar name_attr1_foo name_attr2_bar" }
    end

    context "nested hash" do
      let(:target) { Hoge.new(name: {bar1: Bar.new,bar2: Bar.new}) }

      it { should eq "title_Revenge title_of title_the title_Sith name_bar1_attr1_foo name_bar1_attr2_bar name_bar2_attr1_foo name_bar2_attr2_bar" }
    end
  end

  describe "#wakachi" do
    context "default" do
      class Dummy
        include BabyFace
      end

      let(:baby_face) { Dummy.new }

      it { expect(baby_face.wakachi("aaa bbb")).to eq ["aaa", "bbb"] }
    end
  end
end
