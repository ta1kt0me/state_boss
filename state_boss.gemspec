require_relative 'lib/state_boss/version'

Gem::Specification.new do |spec|
  spec.name          = "state_boss"
  spec.version       = StateBoss::VERSION
  spec.authors       = ["ta1kt0me"]
  spec.email         = ["p.wadachi@gmail.com"]

  spec.summary       = %q{state_boss is state machine for PORO}
  spec.description   = %q{state_boss is state machine for PORO}
  spec.homepage      = "https://github.com/ta1kt0me/state_boss"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.10")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  end

  spec.test_files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(test)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency("byebug", "~> 11.1")
  spec.add_development_dependency("rake", "~> 12.0")
  spec.add_development_dependency("minitest", "~> 5.0")
end
