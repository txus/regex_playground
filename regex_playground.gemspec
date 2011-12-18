# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "regex_playground"
  s.version     = "0.0.1"
  s.authors     = ["Josep M. Bach"]
  s.email       = ["josep.m.bach@gmail.com"]
  s.homepage    = "http://github.com/txus/regex_playground"
  s.summary     = %q{Regex to FSM compiler. Educational purposes only.}
  s.description = %q{Regex to FSM compiler. Educational purposes only.}

  s.rubyforge_project = "regex_playground"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
  s.add_runtime_dependency "ruby-graphviz"
end
