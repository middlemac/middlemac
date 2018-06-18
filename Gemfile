# If you do not have OpenSSL installed, update
# the following line to use "http://" instead
source 'https://rubygems.org'

# Specify your gem's dependencies in middlemac.gemspec
gemspec

group :development do
  gem 'rake'
  gem 'rdoc'
  gem 'yard'
end

group :test do
  gem 'cucumber'
  gem 'aruba'
  gem 'rspec'
end


# These are needed so that Cucumber will work with our fixture. As this
# is not part of the gem, it's probably okay, but seems rather stupid.
# It used to work without this, and Middleman would load its *own* gemfile
# from the fixture. Not sure why that's not happening.
gem 'middleman-targets'
gem 'middleman-syntax'
gem 'middleman-compass'

