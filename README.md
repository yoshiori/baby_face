# BabyFace

baby_face is a simple machine learning module.

![](http://farm3.staticflickr.com/2835/11172696593_2e98d981d0_o.jpg)

## Installation

Add this line to your application's Gemfile:

    gem 'baby_face'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install baby_face

## Usage

### target model( Poro, ActiveModel, ...)
```ruby
class Jedi
  include BabyFace
  baby_face_for features: :name,
                categories: [:light_side, :dark_side]

  attr_accessor :name
  def initialize(name)
    @name = name
  end
end
```

### training

```ruby
Jedi.new("Anakin Skywalker").baby_face.train_light_side
Jedi.new("Darth Maul").baby_face.train_dark_side
```

### classify

```ruby
Jedi.new("Luke Skywalker").baby_face.light_side? # => true
Jedi.new("Darth Vader").baby_face.dark_side? # => true
```

### save training data

```ruby
BabyFace.configuration.data_dir = "/tmp/baby_face"
Jedi.new("Luke Skywalker").baby_face.save # => /tmp/baby_face/jedi.babyface
```


## more
### tokenizer
default : String#split

```ruby
baby_face_for features: :name,
              categories: [:ham, :spam],
              tokenizer: ->(text) {[text.upcase]}

```

### nested object
support nested BabyFace object, array and hash.

```ruby
class Entry < ActiveRecord::Base
  has_many :comments
  include BabyFace
  baby_face_for features: :title, :body, :comments,
                categories: [:ham, :spam]
end

class Comment < ActiveRecord::Base
  include BabyFace
  baby_face_for features: :title, :message
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
