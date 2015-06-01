require 'trax/core/abstract_methods'
class EnumValueBlueprint
  include ::Trax::Core::AbstractMethods

  abstract_class_attribute :tag, :value

  def self.as_json(options={})
    tag.to_s
  end

  def self.enum
    parent
  end

  def self.to_s
    tag.to_s
  end

  def self.to_i
    value
  end

  def self.is_enum_value?(val)
    val == parent
  end

  def self.to_schema
    ::Trax::Core::Definition.new(
      :source => self.name,
      :name => to_s,
      :type => :enum_value,
      :integer_value => to_i
    )
  end

  def self.inspect
    ":#{tag}"
  end

  def self.include?(val)
    self.=== val
  end

  #maybe this is a bad idea, not entirely sure
  def self.==(val)
    self.=== val
  end

  def self.===(val)
    [tag, to_s, to_i].include?(val)
  end
end
