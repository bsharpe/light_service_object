
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "light_service_object/version"

Gem::Specification.new do |spec|
  spec.name          = "light_service_object"
  spec.version       = LightServiceObject::VERSION
  spec.authors       = ["Ben Sharpe"]
  spec.email         = ["bsharpe@gmail.com"]

  spec.summary       = %q{A lightweight base service object for Rails/Ruby}
  spec.description   = %q{Service object based on DRY.rb components for speed and less boilerplate }
  spec.homepage      = "https://github.com/bsharpe/light_service_object"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "dry-initializer", "~> 2.0"
  spec.add_dependency "dry-monads", "~> 1.0"
end
