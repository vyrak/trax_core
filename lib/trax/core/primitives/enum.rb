require 'trax/core/inheritance'

class Enum
  include ::Trax::Core::Inheritance

  def self.define_enum_value(const_name, val)
    name = "#{const_name}".underscore.to_sym

    raise ::Trax::Core::Errors::DuplicateEnumValue.new(:klass => self.class.name, :value => const_name) if key?(name)
    raise ::Trax::Core::Errors::DuplicateEnumValue.new(:klass => self.class.name, :value => val) if value?(val)

    self._values_hash[val] = name
    self._names_hash[name] = val
  end

  def self.key?(name)
    _names_hash.key?(name)
  end

  def self.value?(val)
    _values_hash.key?(val)
  end

  class << self
    delegate :names, :to => '_names_hash'
    delegate :keys, :to => '_names_hash'
    delegate :values, :to => '_names_hash'
  end

  after_inherited do
    instance_variable_set(:@_values_hash, ::Hash.new)
    instance_variable_set(:@_names_hash, ::Hash.new)

    class << self
      attr_accessor :_values_hash
      attr_accessor :_names_hash
    end

    enum_constants = self.constants - [:ClassMethods]
    enum_constants.each do |const_name|
      define_enum_value(const_name, const_get(const_name))
    end
  end
end
