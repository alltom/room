# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{room}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Lieber"]
  s.date = %q{2011-03-17}
  s.default_executable = %q{room}
  s.description = %q{the game is making the game}
  s.email = %q{tom@alltom.com}
  s.executables = ["room"]
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "README",
    "Rakefile",
    "VERSION",
    "bin/room",
    "examples/example1.rb",
    "lib/room.rb",
    "room.gemspec"
  ]
  s.homepage = %q{http://github.com/alltom/room}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{the game is making the game}
  s.test_files = [
    "examples/example1.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
    else
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    end
  else
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
  end
end

