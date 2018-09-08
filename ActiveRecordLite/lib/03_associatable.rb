require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    "#{@class_name.downcase}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    foreign_id = "#{name}_id".to_sym
    defaults = {
      foreign_key: foreign_id,
      primary_key: :id,
      class_name: name.to_s.camelcase.singularize
    }

    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    foreign_id = "#{self_class_name.downcase}_id".to_sym
    defaults = {
      foreign_key: foreign_id,
      primary_key: :id,
      class_name: name.to_s.camelcase.singularize
    }

    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    assoc_options[name] = options

    define_method(name) do
      foreign_value = self.send(options.foreign_key)
      target_class = options.model_class
      results = target_class.where({options.primary_key => foreign_value})
      results.first
    end
  end

  def has_many(name, options = {})
    self_class_name = self.to_s.downcase
    options = HasManyOptions.new(name, self_class_name, options)

    define_method(name) do
      foreign_value = self.send(options.primary_key)
      target_class = options.model_class
      results = target_class.where({options.foreign_key => foreign_value})
      results
    end

  end

  def assoc_options
    @options ||= {}
  end
end

class SQLObject
  extend Associatable
end
