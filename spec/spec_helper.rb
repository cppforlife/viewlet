require "rubygems"
require "bundler/setup"

require "viewlet"

require "haml"
require "haml/template/plugin" # registers HAML with ActionView

module Rails # stub
  def self.root
    Pathname.new(File.expand_path(File.dirname(__FILE__)))
  end
end

class SimpleView < ActionView::Base
  include ActionView::Helpers::CaptureHelper
  include Viewlet::Helpers
end

RSpec.configure do |config|
  config.backtrace_clean_patterns = []
end