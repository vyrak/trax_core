# TraxCore

The active support for Trax / Trax components.

## Trax::Core::Definitions

Allows domain level attribute definitions for your application, gem, library, etc.
Definitions can be extended, passed around, reflected, etc.

``` ruby
module MyFakeEnumNamespace
  extend ::Trax::Core::Definitions
end
```

## Trax::Core::Enum

``` ruby
module MyFakeEnumNamespace
  extend ::Trax::Core::Definitions

  enum :Locale do
    define :en, 1
    define :da, 2
    define :ca, 3
  end

  enum :Category do
    define :default, 1, :display_name => "Default"
    define :clothing, 2, :display_name => "Clothing"
    define :shoes, 3, :display_name => "Shoes"
    define :accessories, 4, :display_name => "Accessories", :deprecated => true
  end

  enum :ExtendedCategory, :extends => "MyFakeEnumNamespace::Category" do
    define :watches,    5
    define :sunglasses, 6
  end
end
```

**Abstract use examples**

``` ruby
MyFakeEnumNamespace::Locale.values
=> [1, 2, 3]
MyFakeEnumNamespace::Locale.new(:en)
=> :en
MyFakeEnumNamespace::Locale.new(:en).to_i
=> 1
MyFakeEnumNamespace::Locale.new(1)
=> :en
```

One advantage of Trax::Core enums over other enum implementations, is the ability
to attach metadata to your enum values. This is useful in a variety of circumstances,
mapping values, having descriptive labels, etc. Anything that is not a reserved key,
can be passed into the definition and later reflected upon.

``` ruby
MyFakeEnumNamespace::Category.choices[1][:display_name]
=> "Clothing"
```

**Reflecting**
``` ruby
MyFakeEnumNamespace::Category.to_schema
=>
{"name"=>"category",
 "source"=>"MyFakeEnumNamespace::Category",
 "type"=>:enum,
 "choices"=>
  [{"source"=>"MyFakeEnumNamespace::Category::Default", "name"=>"default", "type"=>:enum_value, "integer_value"=>1, "attributes"=>{"display_name"=>"Default"}},
   {"source"=>"MyFakeEnumNamespace::Category::Clothing", "name"=>"clothing", "type"=>:enum_value, "integer_value"=>2, "attributes"=>{"display_name"=>"Clothing"}},
   {"source"=>"MyFakeEnumNamespace::Category::Shoes", "name"=>"shoes", "type"=>:enum_value, "integer_value"=>3, "attributes"=>{"display_name"=>"Shoes"}}],
 "values"=>[:default, :clothing, :shoes]}
```

Note that the deprecated value is not included in the to_schema call above.
The standard rule with enums is never delete any values, only deprecate.
That will ensure your api's are always backwards compatible.
(i.e. you delete an option, but have records in database with that option still)
To schema is mainly intended to be used for the sake of front end knowing about backend,
validation, etc.

## Trax::Core::NamedClass
**Create a non anonymous class via a fully qualified class name**
*note namespace it is created in must exist prior to creation*

Trax::Core::NamedClass.new instead of Class.new differences

1. Defines class within namespace, so no thing = some_module.const_set("Blah", Class.new) needed
2. Allows you to access the created class name within the definition block, i.e.
``` ruby
myklass = some_module.const_set("Blah", Class.new do
  puts name
end)
=> nil
```

Will put nil, as its referencing the anonymous class. However:
``` ruby
::Trax::Core::NamedClass.new("SomeModule::Blah") do
  puts name
end
=> "SomeModule::Blah"
```
Holds reference to actual class being created.

3. Allows you to pass an options hash which gets evaluated as class_attribute accessor

``` ruby
module Html
  class Element
  end
end

::Trax::Core::NamedClass.new(
  "Html::DivWithDimensions",
  Html::Element,
  :default_height => "220px",
  :default_width => "220px"
)

Html::Div.default_height => "220px"
Html::Div.default_width => "220px"
```

^ is probably a bad example, but you get the idea. Also note param 2 is the class you
want to inherit from, which differs from the Class.new api which expects 1st param
to be the class you are inheriting from. Broke from that api since its optional,
and the thing that is not optional with a named class, is obviously the name.

## Trax::Core::NamedModule
**Create a non anonymous module via a fully qualified module name**
*note namespace it is created in must exist prior to creation*

### examples: (by default, any module args passed after the name of the module will be applied via extend)
**With Args:**
``` ruby
Trax::Core::NamedModule.new("Ecommerce::ItemExtensions", PricingExtension, ShippingExtension)

=> mod = Ecommerce.const_set("ItemExtensions")
   mod.extend(PricingExtension)
   mod.extend(ShippingExtension)
```

**With :extensions keyword**
``` ruby
Trax::Core::NamedModule.new("Ecommerce::ItemExtensions", :extensions => [::Ecommerce::PricingExtension])
```

**With :includes keyword**
``` ruby
Trax::Core::NamedModule.new("Ecommerce::ItemExtensions", :includes => [::Ecommerce::ShippingExtension])
```

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
