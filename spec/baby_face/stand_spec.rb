require "baby_face"

describe BabyFace::Stand do

  describe "#to_feature" do
    subject { target.baby_face.to_feature }

    class Hoge
      include BabyFace
      attr_accessor :title, :name
      baby_face_for features: [:title, :name]

      def initialize(title: "Revenge of the Sith", name: "Anakin Skywalker")
        @title = title
        @name = name
      end
    end

    class Bar
      include BabyFace
      attr_accessor :attr1, :attr2
      baby_face_for features: [:attr1, :attr2]

      def initialize(attr1: "foo", attr2: "bar")
        @attr1 = attr1
        @attr2 = attr2
      end
    end

    context "Simple object" do
      let(:target) { Hoge.new }

      it { should eq "title_Revenge title_of title_the title_Sith name_Anakin name_Skywalker" }
    end

    context "Nested object" do
      let(:target) { Hoge.new(name: Bar.new) }

      it { should eq "title_Revenge title_of title_the title_Sith name_attr1_foo name_attr2_bar" }
    end

    context "Nested array" do
      let(:target) { Hoge.new(name: [Bar.new, Bar.new]) }

      it { should eq "title_Revenge title_of title_the title_Sith name_attr1_foo name_attr2_bar name_attr1_foo name_attr2_bar" }
    end

    context "Nested hash" do
      let(:target) { Hoge.new(name: {bar1: Bar.new,bar2: Bar.new}) }

      it { should eq "title_Revenge title_of title_the title_Sith name_bar1_attr1_foo name_bar1_attr2_bar name_bar2_attr1_foo name_bar2_attr2_bar" }
    end
  end

  describe "#wakachi" do
    context "Default" do
      class Dummy
        include BabyFace
        attr_accessor :name
        baby_face_for features: :name
      end
      let(:baby_face) { Dummy.new.baby_face }

      it { expect(baby_face.send(:wakachi, "aaa bbb")).to eq ["aaa", "bbb"] }
    end

    context "Use tokenizer" do
      class Dummy2
        include BabyFace
        attr_accessor :name
        baby_face_for features: :name,
                         tokenizer: ->(text) {[text.upcase]}

      end
      let(:baby_face) { Dummy2.new.baby_face }

      it { expect(baby_face.send(:wakachi, "aaa bbb")).to eq ["AAA BBB"] }
    end
  end

  describe "#train" do
    class Jedi
      include BabyFace
      attr_accessor :name
      baby_face_for features: :name,
                       categories: [:light_side, :dark_side]

      def initialize(name)
        @name = name
      end
    end

    it 'train jedi' do
      10.times {
        Jedi.new("Anakin Skywalker").baby_face.train_light_side
      }

      10.times {
        Jedi.new("Darth Maul").baby_face.train_dark_side
      }

      luke = Jedi.new("Luke Skywalker")
      vader = Jedi.new("Darth Vader")

      expect(luke.baby_face).to be_light_side
      expect(vader.baby_face).to be_dark_side
    end
  end
end
