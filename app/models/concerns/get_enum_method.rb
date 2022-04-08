# enumを使用した場合に、国際化を簡単にするために作成
# classメソッドとして使用するため、extendで使用。

module GetEnumMethod
  extend ActiveSupport::Concern

  def def_human_enum_(*attr_names)
    attr_names.each do |attr_name|
      method_name = "human_enum_#{attr_name}"
      define_singleton_method(method_name) do |value|
        human_attribute_name("#{attr_name}.#{value}")
      end
    end
  end

  def enum_options_for_select(attr_name)
    send(attr_name.to_s.pluralize).reduce({}) do |hash, (key, _)|
      hash.merge({send("human_enum_#{attr_name}", key) => key})
    end
  end
end
