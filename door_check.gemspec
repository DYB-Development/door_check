require_relative "lib/door_check/version"

Gem::Specification.new do |spec|
  spec.name        = "door_check"
  spec.version     = DoorCheck::VERSION
  spec.authors     = [ "Tyler Schneider" ]
  spec.email       = [ "tylercschneider@gmail.com" ]
  spec.homepage    = "https://github.com/DYB-Development/door_check"
  spec.summary     = "Sign-in methods and second steps an app offers, each account narrows, and each person chooses from."
  spec.description = "Records which methods proved a person in each sign-in, and checks that record against the rule of each account the person enters."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib,the_local}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1"
  spec.add_dependency "keystone_ui", ">= 0.50"
  spec.add_dependency "rotp", ">= 6.0"
  spec.add_dependency "rqrcode", ">= 2.0"
  spec.add_dependency "webauthn", ">= 3.0"
  spec.add_dependency "turbo-rails", ">= 2.0"
end
