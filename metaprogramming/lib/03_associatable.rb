require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    self.class_name.constantize
  end

  def table_name
    # ...
    if self.class_name == "Human"
      return "humans"
    else
      self.class_name.tableize
    end
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    if options.key?(:primary_key)
      @primary_key = options[:primary_key]
    else
      @primary_key = :id 
    end
    if options.key?(:foreign_key)
      @foreign_key = options[:foreign_key]
    else 
      @foreign_key = (name.to_s.underscore + '_id').to_sym
    end
    if options.key?(:class_name)
      @class_name = options[:class_name]
    else
      @class_name = name.to_s[0].upcase + name.to_s[1..-1]
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    if options.key?(:primary_key)
      @primary_key = options[:primary_key]
    else
      @primary_key = :id 
    end
    if options.key?(:foreign_key)
      @foreign_key = options[:foreign_key]
    else 
      @foreign_key = (self_class_name.to_s.underscore + '_id').to_sym
    end
    if options.key?(:class_name)
      @class_name = options[:class_name]
    else
      singular = name.singularize
      @class_name = singular.to_s[0].upcase + singular.to_s[1..-1]
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    options = BelongsToOptions.new(name, options)
    debugger
    define_method(:belongs_to) do 
      #options.send(:foreign_key)
      #options.model_class
    end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
