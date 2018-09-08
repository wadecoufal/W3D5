require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    byebug
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      foreign_value = self.send(through_options.foreign_key)
      target_class = source_options.model_class
      results = target_class.where({source_options.primary_key => foreign_value})
      results.first
    end
  end
end
