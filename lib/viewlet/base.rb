module Viewlet
  class Base
    def initialize(name, view)
      @name = name
      @view = view
      @variables = {
        @name.to_sym => self,
        :unique_id => "viewlet_#{rand(36**20).to_s(36)}"
      }
    end

    def render
      file_path = Rails.root.join("app/viewlets/#{@name}/plugin").to_s
      @view.render(:file => file_path, :locals => @variables)
    end

    private

    def method_missing(method, *args, &block)
      is_write_op = if @variables[method].is_a?(Proc)
        block.present?
      else
        args.any? || block.present?
      end

      send("_#{is_write_op ? :write : :read}_variable", method, *args, &block)
    end

    def _read_variable(name, *args, &block)
      if @variables[name].is_a?(Proc)
        @view.capture(*args, &@variables[name])
      else
        @variables[name]
      end
    end

    def _write_variable(name, *args, &block)
      @variables[name] = if block
        # HAML changes argument-less block {|| } into block {|*a| }
        # which makes block.arity to be -1 instead of just 0
        block.arity == -1 ? @view.capture(&block) : block
      else
        args.first
      end
    end
  end
end