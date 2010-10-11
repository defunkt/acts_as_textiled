require 'action_view'

class ActionView::Helpers::InstanceTag
  class << self
    def value_before_type_cast_with_textiled(object, method_name)
      if !object.nil? && object.class.respond_to?(:textiled_attributes) && object.class.textiled_attributes.include?(method_name.to_sym)
        object.send(method_name + "_source")
      else
        value_before_type_cast_without_textiled(object, method_name)
      end
    end

    alias_method :value_before_type_cast_without_textiled, :value_before_type_cast
    alias_method :value_before_type_cast, :value_before_type_cast_with_textiled
  end
end