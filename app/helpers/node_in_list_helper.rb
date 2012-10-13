module NodeInListHelper
  class NodeInList < BlockHelpers::Base
    def initialize(instance, opts = {})
      @instance = instance
      @clazz = opts[:class]
    end

    def display(body)
      content_tag :span, :class => "#{@clazz} node_in_list #{@instance.to_param}" do
        body
      end
    end
  end
end
