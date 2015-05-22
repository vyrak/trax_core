require 'trax/core/inheritance'

class Enum
  include ::Trax::Core::Inheritance

  ### Class Methods ###
  def self.define_enum_value(const_name, val)
    name = "#{const_name}".underscore.to_sym

    raise ::Trax::Core::Errors::DuplicateEnumValue.new(:klass => self.class.name, :value => const_name) if key?(name)
    raise ::Trax::Core::Errors::DuplicateEnumValue.new(:klass => self.class.name, :value => val) if value?(val)

    self._values_hash[val] = ::EnumValue.new(name: name, value: val)
    self._names_hash[name] = ::EnumValue.new(name: name, value: val)
  end

  def self.[](val)
    if ::Is.numeric?(val)
      self._values_hash[val]
    elsif ::Is.symbolic?(val)
      val = val.to_sym if val.is_a?(String)
      self._names_hash[val]
    end
  end

  def self.key?(name)
    _names_hash.key?(name)
  end

  def self.names
    _names_hash.values
  end

  def self.keys
    _names_hash.keys
  end

  def self.value?(val)
    _values_hash.key?(val)
  end

  def self.values
    _names_hash.values.map(&:to_i)
  end

  ### Hooks ###
  after_inherited do
    instance_variable_set(:@_values_hash, ::Hash.new)
    instance_variable_set(:@_names_hash, ::Hash.new)
    instance_variable_set(:@_names_as_strings, [])

    class << self
      attr_accessor :_values_hash
      attr_accessor :_names_hash
      #so we can prevent memory leaks by not casting string to symbol if invalid
      attr_accessor :_names_as_strings
    end

    enum_constants = self.constants - [:ClassMethods]
    enum_constants.each do |const_name|
      define_enum_value(const_name, const_get(const_name))
    end

    _names_as_strings << names.map(&:to_s)
  end

  ### Instance Methods ###
  attr_accessor :choice

  def initialize(val)
    self.choice = val
  end

  def choice=(val)
    if ::Is.numeric?(val)
      raise ::Trax::Core::InvalidEnumOption.new(:klass => self.class.name, :value => val) unless self.class.value?(val)
      @choice = self.class._values_hash[val]
    elsif ::Is.symbolic?(val)
      raise ::Trax::Core::InvalidEnumOption.new(:klass => self.class.name, :value => val) unless self.class.key?(val)
      @choice = self.class._names_hash[val]
    else
      raise ::Trax::Core::InvalidEnumOption.new(:klass => self.class.name, :value => val) unless @choice
    end

    @choice
  end
end
