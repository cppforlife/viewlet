# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "viewlet/version"

Gem::Specification.new do |s|
  s.name        = "viewlet"
  s.version     = Viewlet::VERSION
  s.authors     = ["Dmitriy Kalinin"]
  s.email       = ["cppforlife@gmail.com"]
  s.homepage    = "https://github.com/cppforlife/viewlet"
  s.summary     = "Rails view components"
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "actionpack"

  s.add_development_dependency "rspec"
  s.add_development_dependency "haml"
end
