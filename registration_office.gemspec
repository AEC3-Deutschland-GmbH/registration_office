# frozen_string_literal: true

require_relative 'lib/registration_office/version'

Gem::Specification.new do |spec|
  spec.name = 'registration_office'
  spec.version = RegistrationOffice::VERSION
  spec.authors = ['Eric Kaulfuß']
  spec.email = ['ek@aec3.de']

  spec.summary = 'Allows named registers within modules and classes'
  spec.description = <<~DESCRIPTION
    Allows named registers within modules and classes
  DESCRIPTION
  spec.homepage = 'https://github.com/araccaine/registration_office'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  # spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
