module SomeConcern
  extend ::Trax::Core::Concern

  SOME_MOD_CONST = :Blahgity

  included do
    self.instance_variable_set(:@something_on_included, "something_on_included")
  end

  after_included do
    self.const_set("SOMETHING", "ANYTHING")
    self.instance_variable_set(:@otherthing, "otherthing")
  end

  after_extended do |base|
    self.module_attribute(:some_mod_attribute) { [ base::SOME_MOD_CONST ] }
  end
end

module SomeConcernConcern
  extend ::SomeConcern
end

class SomeKlass
  include ::SomeConcern
end
