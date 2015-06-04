source 'https://rubygems.org'

group :development, :test do
  gem 'pry',                     :require => false
  gem 'puppet-lint',             :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'rake',                    :require => false
  gem 'rspec-puppet',            :require => false
  # rspec must be v2 for ruby 1.8.7
  if RUBY_VERSION >= '1.8.7' and RUBY_VERSION < '1.9'
    gem 'rspec', '~> 2.0',         :require => false
  end
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
