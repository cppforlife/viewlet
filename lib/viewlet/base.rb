module Viewlet
  class Base
    def initialize(name, view)
      @name = name
      @view = view
      @variables = {
        :unique_id => "viewlet_#{rand(36**20).to_s(36)}"
      }
    end

    def method_missing(method, *args, &block)
      @variables[method] = if block_given?
        # HAML changes argument-less block {|| } into block {|*a| }
        # which makes block.arity to be -1 instead of just 0
        block.arity == -1 ? @view.capture(&block) : block
      else
        args.first
      end
    end

    def render
      file_path = Rails.root.join("app/viewlets/#{@name}/plugin").to_s
      @view.render(:file => file_path, :locals => @variables)
    end
  end
end