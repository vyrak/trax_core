# require_relative 'transformer/property'
#
# module Trax
#   module Core
#     class Transformer < SimpleDelegator
#       attr_reader :input, :parent, :output
#
#       def self.inherited(subklass)
#         subklass.class_attribute :properties
#         subklass.properties = {}.with_indifferent_access
#         subklass.class_attribute :after_initialize_callbacks
#         subklass.after_initialize_callbacks = ::Set.new
#         subklass.class_attribute :after_transform_callbacks
#         subklass.after_transform_callbacks = ::Set.new
#       end
#
#       def self.after_initialize(&block)
#         after_initialize_callbacks << block
#       end
#
#       def self.after_transform(&block)
#         after_transform_callbacks << block
#       end
#
#       def self.properties_with_default_values
#         @properties_with_default_values ||= properties.values.select{ |prop| prop.try(:default) }
#       end
#
#       def self.nested_properties
#         @nested_properties ||= properties.values.select{|prop| prop.is_nested? }
#       end
#
#       def self.transformer_properties
#         @transformer_properties ||= properties.values.select{|prop| prop.ancestors.include?(::Trax::Core::Transformer) }
#       end
#
#       def self.transformer_properties_with_after_transform_callbacks
#         @transformer_properties_with_after_transform_callbacks ||= transformer_properties.select{|prop| prop.after_transform_callbacks.any? }
#       end
#
#       def self.input_properties
#         @input_properties ||= properties.values.select{ |prop| prop.is_source_input? }
#       end
#
#       def self.computed_properties
#         @computed_properties ||= properties.values.reject{ |prop| prop.is_source_input? }
#       end
#
#       def self.is_nested?
#         !!self.try(:parent_definition)
#       end
#
#       def self.from_parent?
#         false
#       end
#
#       def self.property(_property_name, **options, &block)
#         options[:parent_definition] = self
#         options[:property_name] = _property_name
#         options[:with] = block if block_given?
#         options[:from] = options[:property_name] unless options[:from]
#         transformer_klass_name = "#{name}::#{_property_name.camelize}"
#         transformer_klass = ::Trax::Core::NamedClass.new(transformer_klass_name, Property, **options)
#         self.properties[_property_name] = transformer_klass
#       end
#
#       def self.transformer(_property_name, **options, &block)
#         options[:parent_definition] = self
#         options[:property_name] = _property_name
#         options[:default] = ->(){ {}.with_indifferent_access } unless options.key?(:default)
#         options[:with] = block if block_given?
#         transformer_klass_name = "#{name}::#{_property_name.camelize}"
#         transformer_klass = ::Trax::Core::NamedClass.new(transformer_klass_name, Transformer, **options, &block)
#         self.properties[_property_name] = transformer_klass
#       end
#
#       def self.nested(*args, **options, &block)
#         transformer(*args, **options, &block)
#       end
#
#       def self.fetch_property_from_object(_property, obj)
#         if _property.include?('/')
#           property_chain = _property.split('/')
#           obj.dig(*property_chain)
#         else
#           obj[_property]
#         end
#       end
#
#       def self.object_has_property?(_property, obj)
#         !!fetch_property_from_object(_property, obj)
#       end
#
#       def self.any_objects_have_property?(_property, *objects)
#         objects.any?{ |obj| object_has_property?(obj) }
#       end
#
#       def initialize(obj={}, parent=nil)
#         @input = obj.dup
#         @output = {}.with_indifferent_access
#         @parent = parent if parent
#
#         initialize_output_properties
#         # initialize_default_values
#         run_after_initialize_callbacks if run_after_initialize_callbacks?
#         run_after_transform_callbacks if run_after_transform_callbacks?
#       end
#
#       def [](_property)
#         if _property.include?('/')
#           property_chain = _property.split('/')
#           self.dig(*property_chain)
#         else
#           super(_property)
#         end
#       end
#
#       def key?(_property)
#         if _property.include?('/')
#           property_chain = _property.split('/')
#           !!self.dig(*property_chain)
#         else
#           super(_property)
#         end
#       end
#
#       def has_parent?
#         !!parent
#       end
#
#       def parent_key?(k)
#         return false unless has_parent?
#
#         parent.key?(k)
#       end
#
#       def __getobj__
#         @output
#       end
#
#       def to_hash
#         @to_hash ||= begin
#           duplicate_hash = self.__getobj__.dup
#
#           duplicate_hash.each_pair do |k, v|
#             if v.is_a?(::Trax::Core::Transformer)
#               duplicate_hash[k] = v.__getobj__
#             elsif v.is_a?(Property)
#               duplicate_hash[k] = v.__getobj__
#             end
#           end
#
#           duplicate_hash
#         end
#       end
#
#       def to_recursive_hash
#         @to_recursive_hash ||= begin
#           duplicate_hash = self.__getobj__.dup
#
#           self.each_pair do |k, v|
#             if v.is_a?(::Trax::Core::Transformer)
#               duplicate_hash[k] = v.to_hash
#             elsif v.is_a?(Property)
#               duplicate_hash[k] = v.__getobj__
#             end
#           end
#
#           duplicate_hash
#         end
#       end
#
#       private
#
#       def initialize_default_values
#         self.class.properties_with_default_values.each do |prop|
#           unless @output.key?(prop.property_name)
#             if prop.default.is_a?(Proc)
#               @output[prop.property_name] = prop.default.arity > 0 ? prop.default.call(@output) : prop.default.call
#             else
#               @output[prop.property_name] = prop.default
#             end
#           end
#         end
#       end
#
#       def initialize_output_properties
#         self.class.input_properties.each do |property_klass|
#           @output[property_klass.output_key] = property_klass.new(self)
#         end
#
#         self.class.computed_properties.each do |property_klass|
#           @output[property_klass.output_key] = property_klass.new(self)
#         end
#
#         self
#       end
#
#       #will not transform output based on callback result
#       def run_after_initialize_callbacks
#         self.class.after_initialize_callbacks.each do |callback|
#           @output.instance_eval(&callback)
#         end
#       end
#
#       def run_after_initialize_callbacks?
#         self.class.after_initialize_callbacks.any?
#       end
#
#       #will transform output with return of each callback
#       def run_after_transform_callbacks
#         self.class.after_transform_callbacks.each do |callback|
#           @output = self.instance_exec(@output, &callback)
#         end
#       end
#
#       def run_after_transform_callbacks?
#         self.class.after_transform_callbacks.any?
#       end
#     end
#
#     # class Property < SimpleDelegator
#     #   def self.is_nested?
#     #     return @is_nested if defined?(@is_nested)
#     #     @is_nested = !!try(:parent_definition)
#     #   end
#     #
#     #   def self.is_translated?
#     #     return @is_translated if defined?(@is_translated)
#     #     @is_translated = !!try(:from)
#     #   end
#     #
#     #   def self.is_callable?
#     #     return @is_callable if defined?(@is_callable)
#     #     @is_callable = try(:with) && try(:with).is_a?(Proc)
#     #   end
#     #
#     #   def self.has_default_value?
#     #     return @has_default_value if defined?(@has_default_value)
#     #     @has_default_value = !!try(:default)
#     #   end
#     #
#     #   def self.from_parent?
#     #     return @from_parent if defined?(@from_parent)
#     #     @from_parent = !!try(:from_parent)
#     #   end
#     #
#     #   def self.is_transformer?
#     #     return @is_transformer if defined?(@is_transformer)
#     #     @is_transformer = ancestors.include?(::Trax::Core::Transformer)
#     #   end
#     #
#     #   def self.is_source_output?
#     #     return @is_source_output if defined?(@is_source_output)
#     #     @is_source_output = (try(:source) && try(:source) == :output) || false
#     #   end
#     #
#     #   def self.is_source_input?
#     #     return @is_source_input if defined?(@is_source_input)
#     #     @is_source_input = !is_source_output?
#     #   end
#     #
#     #   def self.input_key
#     #     @input_key ||= self.try(:from) ? self.from : self.property_name
#     #   end
#     #
#     #   def self.input_key_chain
#     #     @input_key_chain ||= input_key.split("/")
#     #   end
#     #
#     #   def self.output_key
#     #     @output_key ||= self.try(:as) ? self.as : self.property_name
#     #   end
#     #
#     #   def initialize(transformer)
#     #     @transformer = transformer
#     #     set_value
#     #     transform_value if self.class.is_callable?
#     #     set_default_value if set_default_value?
#     #   end
#     #
#     #   def nil?
#     #     __getobj__.nil?
#     #   end
#     #
#     #   def __getobj__
#     #     @value
#     #   end
#     #
#     #   def value
#     #     @value
#     #   end
#     #
#     #   private
#     #
#     #   def default_property_value
#     #     if self.class.default.is_a?(Proc)
#     #       self.class.default.arity > 0 ? self.class.default.call(@transformer) : self.class.default.call
#     #     else
#     #       self.class.default
#     #     end
#     #   end
#     #
#     #   def transform_value
#     #     @value = self.class.with.arity > 1 ? self.class.with.call(@value, @transformer) : self.class.with.call(@value)
#     #   end
#     #
#     #   def fetch_property_value
#     #     target.dig(*self.class.input_key_chain)
#     #   end
#     #
#     #   def set_value
#     #     @value = fetch_property_value
#     #   end
#     #
#     #   def set_default_value
#     #     @default_value = default_property_value
#     #   end
#     #
#     #   def set_default_value?
#     #     @value.nil? && self.class.has_default_value?
#     #   end
#     #
#     #   def target
#     #     @target ||= if self.class.from_parent?
#     #       @transformer.parent.input
#     #     elsif !self.class.is_source_output?
#     #       @transformer.input
#     #     else
#     #       @transformer.output
#     #     end
#     #   end
#     # end
#   end
# end
