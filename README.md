# TraxCore

The active support for Trax / Trax components.

### EagerAutoloadNamespace

Wish you could eager load all of the paths in a particular namespace directory,
eagerly? Say you have the following directory tree you're trying to autoload:

whatever.rb
``` ruby
module Whatever
  extend ::ActiveSupport::Autoload

  eager_autoload do
    autoload :Widget
    autoload :Thing
  end
end

Whatever.eager_load!
```
whatever/widget.rb
``` ruby
module Whatever
  module Widget
  end
end
```

Now you just have to do:

``` ruby
module Whatever
  include ::Trax::Core::EagerAutoloadNamespace
end
```

Note, it cant handle all caps namespaces, i.e. it would break if namespace were WIDGETS,
as it just uses classify on the file base name to define the autoload block.


## Installation

Add this line to your application's Gemfile:

    gem 'trax_core'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install trax_core

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/trax_core/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
