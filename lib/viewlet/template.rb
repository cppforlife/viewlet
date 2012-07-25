require "action_view"

module Viewlet
  class Template
    def self.find(name)
      args = [name, "", false, {:locale => [:en], :formats => [:html], :handlers => [:erb, :haml]}, nil]
      template = path_resolver.find_all(*args).first ||
        raise(ActionView::MissingTemplate.new([path_resolver], *args))

      # Cannot refresh template because it will try to use
      # view's lookup context which will not include app/viewlets dir
      template.virtual_path = nil

      new(template)
    end

    def initialize(template)
      @template = template
    end

    def render(view, variables={})
      @template.locals = variables.keys
      @template.render(view, variables)
    end

    private

    def self.path_resolver
      ActionView::FileSystemResolver.new \
        Rails.root.join("app/viewlets"), "{:action/,}:action{.:locale,}{.:formats,}{.:handlers,}"
    end
  end
end