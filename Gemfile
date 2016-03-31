source ENV["GEM_SOURCE"] || "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV["PUPPET_GEM_VERSION"] || "~> 3.8.0"
  gem "rspec"
  gem "rspec-puppet", :git => "https://github.com/rodjek/rspec-puppet.git"
  gem "puppetlabs_spec_helper"
  gem "json"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem "ci_reporter_rspec"
  gem "rubocop"
  gem "simplecov"
  gem "simplecov-console"

  gem "puppet-lint"
  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-leading_zero-check"
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-version_comparison-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-unquoted_string-check"
  gem "puppet-lint-empty_string-check"
  gem "puppet-lint-spaceship_operator_without_tag-check"
  gem "puppet-lint-variable_contains_upcase"
  gem "puppet-lint-undef_in_function-check"
  gem "puppet-lint-file_ensure-check"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-puppet_install_helper"
end
