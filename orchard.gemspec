# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'orchard/version'

Gem::Specification.new do |s|
  s.name        = "orchard"
  s.version     = Orchard::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stephanie Collett"]
  s.email       = ["stephanie.collett@ucop.edu"]
  # s.homepage    = "http://github.com/scollett/orchard"
  s.summary     = "Pairtree implmentation for Ruby"
  s.description = "Orchard translates id strings to/from Pairtree paths for use with Pairtree file repositories."
 
  s.required_rubygems_version = ">= 1.3.6"
  # s.rubyforge_project         = "orchard"
 
  s.add_development_dependency "thoughtbot-shoulda"
 
  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README.md)
  s.require_path = 'lib'
end