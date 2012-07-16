module Viewlet
  module Helpers
    def viewlet(name, options={}, &block)
      klass = options[:class_name].try(:constantize) || Base
      viewlet = klass.new(name, self)

      case block.arity
        when 0 then block.call
        when 1 then block.call(viewlet)
      end if block_given?

      viewlet.render
    end
  end
end