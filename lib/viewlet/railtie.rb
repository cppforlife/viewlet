module Viewlet
  class Railtie < ::Rails::Railtie
    initializer "viewlet.view_helpers" do
      ActionView::Base.send :include, Viewlet::Helpers
    end

    config.before_configuration do
      require "viewlet/haml" if defined?(Haml)
    end

    config.to_prepare do |app|
      Rails.application.config.assets.paths << Rails.root.join("app", "viewlets")
    end
  end
end