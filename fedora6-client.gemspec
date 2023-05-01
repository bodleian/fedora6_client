# frozen_string_literal: true

require_relative "lib/fedora6/client/module_version"

Gem::Specification.new do |spec|
  spec.name = "fedora6-client"
  spec.version = Fedora6::Client::VERSION
  spec.authors = ["Tom Wrobel"]
  spec.email = ["thomas.wrobel@bodleian.ox.ac.uk"]

  spec.summary = "A Fedora6 API client"
  spec.description = "Rails gem for interaction with the Fedora6 repository system"
  spec.homepage = "https://gitlab.bodliena.ox.ac.uk/ORA4/fedora6.client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://gitlab.bodliena.ox.ac.uk/ORA4/fedora6.client"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://gitlab.bodliena.ox.ac.uk/ORA4/fedora6.client"
  spec.metadata["changelog_uri"] = "https://gitlab.bodliena.ox.ac.uk/ORA4/fedora6.client/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'net-http-persistent'
  spec.add_dependency 'rspec'
  spec.add_dependency 'byebug'
  spec.add_dependency 'webmock'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
