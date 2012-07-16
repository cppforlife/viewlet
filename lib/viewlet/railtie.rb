module Viewlet
  class Railtie < ::Rails::Railtie
    initializer "viewlets.view_helpers" do
      ActionView::Base.send :include, Viewlet::Helpers
    end

    config.to_prepare do |app|
      Rails.application.config.assets.paths << Rails.root.join("app", "viewlets")
    end
  end
end