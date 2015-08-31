::Trax::Core::NamedClass.new("FakeNamespace::Something", String)
::Trax::Core::NamedClass.new("FakeNamespace::SomeBlankClass")
::Trax::Core::NamedClass.new("FakeNamespace::Dmx") do
  class_attribute :whats_my_name

  self.whats_my_name = self.name.underscore
end

::Trax::Core::NamedClass.new("FakeNamespace::ClassWithAttributes", :length => 20, :height => 15)
