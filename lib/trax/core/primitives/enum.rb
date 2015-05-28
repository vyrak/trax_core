require 'trax/core/inheritance_hooks'

### Examples
# ProductCategory < Enum
#   CLOTHING = 1
#   SHOES = 2
#   ACCESSORIES = 3
# end
# ProductCategory.keys => [:clothing, :shoes, :accessories]

# StoreYearlyRevenue < Enum
#   :'0_100000' = 1
#   :'100000_999999' = 2
#   :'1000000_99999999' = 3
# end

### Accepts either an integer or the name when setting a value
# ProductCategory.new(1) => #{name: :clothing, :value => 1}

class Enum < SimpleDelegator
  include ::Trax::Core::InheritanceHooks

  class_attribute :allow_nil, :raise_on_invalid

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

  def self.define(*args)
    define_enum_value(*args)
  end

  def self.keys
    _names_hash.keys
  end

  def self.key?(name)
    _names_hash.key?("#{name}")
  end

  def self.names
    _names_hash.values
  end

  #so we can prevent memory leaks by not casting string to symbol if invalid
  #and memoize it
  def self._names_as_strings
    @_names_as_strings ||= names.map(&:to_s)
  end

  def self.no_raise_mode?
    !raise_on_invalid
  end

  def self.valid_name?(val)
    _names_as_strings.include?(val)
  end

  def self.valid_value?(val)
    values.include?(val)
  end

  #because calling valid_value? in the define_enum_value method is unclear
  def self.value?(val)
    valid_value?(val)
  end

  def self.valid_choice?(val)
    _names_hash.values.include?("#{val}")
  end

  def self.values
    _names_hash.values.map(&:to_i)
  end

  class << self
    alias :enum_value :define_enum_value
    alias :define :define_enum_value
    attr_accessor :_values_hash
    attr_accessor :_names_hash
  end

  ### Hooks ###
  on_inherited do
    instance_variable_set(:@_values_hash, ::Hash.new)
    instance_variable_set(:@_names_hash, ::Hash.new)
    instance_variable_set(:@_names_as_strings, nil)
    self.allow_nil = false
    self.raise_on_invalid = false
  end

  after_inherited do
    enum_constants = self.constants - [:ClassMethods]
    enum_constants.each do |const_name|
      define_enum_value(const_name, const_get(const_name))
    end if enum_constants.any?
  end

  ### Instance Methods ###
  attr_accessor :choice

  def initialize(val)
    self.choice = val unless val.nil? && self.class.allow_nil
  end

  def choice=(val)
    @choice = valid_choice?(val) ? self.class[val] : nil

    raise ::Trax::Core::Errors::InvalidEnumValue.new(
      :field => self.class.name,
      :value => val
    ) if self.class.raise_on_invalid && !@choice

    @choice
  end

  def __getobj__
    @choice
  end

  def to_s
    choice.to_s
  end

  def to_json
    choice.value
  end

  # def to_hash
  #   @choice.try(:value)
  # end

  def valid_choice?(val)
    if ::Is.numeric?(val)
      self.class.valid_value?(val)
    elsif ::Is.symbolic?(val)
      self.class.valid_name?(val.try(:to_s))
    else
      false
    end
  end
end
