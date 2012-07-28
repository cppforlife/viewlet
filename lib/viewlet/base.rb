require "viewlet/template"

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
      Template.find(@name.to_s).render(@view, @variables)
    end

    private

    def method_missing(variable_name, *args, &block)
      is_write_op = if @variables[variable_name].is_a?(Proc)
        block.present?
      else
        args.any? || block.present?
      end

      send("_#{is_write_op ? :write : :read}_variable", variable_name, *args, &block)
    end

    def _read_variable(name, *args, &block)
      if @variables[name].is_a?(Proc)
        @variables[name].call(*args)
      else
        @variables[name]
      end
    end

    def _write_variable(name, *args, &block)
      @variables[name] = if block
        # HAML changes argument-less block {|| } into block {|*a| }
        # which makes block.arity to be -1 instead of just 0
        if block.arity == -1
          @view.capture(&block)
        else
          Proc.new { |*a| @view.capture(*a, &block) }
        end
      else
        args.first
      end
    end
  end
end