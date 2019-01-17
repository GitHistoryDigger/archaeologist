lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
Gem::Specification.new { |s|
  s.name = 'archaeologist'
  s.version = '0.0.0'
  s.license = 'MIT'
  s.date = `date --iso`
  s.summary = 'Language detector for git'
  s.description = 'Github-linguist based language detector per a commit'
  s.author = 'Hiroaki Yamamoto'
  s.email = 'rubygems@hysoftware.net'

  s.files = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  [
    ["github-linguist", "~> 7.0"],
    ["parallel", "~> 1.12"],
  ].each { |gem|
    s.add_runtime_dependency(*gem)
  }
  [
    ["rspec", "~> 3.8"],
    ["simplecov", "~> 0.16.1"],
  ].each { |gem|
    s.add_development_dependency(*gem)
  }
}
