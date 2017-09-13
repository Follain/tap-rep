# frozen_string_literal: true

require File.expand_path('../lib/tap_rep/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'tap-rep'
  s.version      = TapRep::VERSION
  s.platform     = Gem::Platform::RUBY
  s.date         = '2017-06-21'
  s.summary      = 'Singer.io tap for Rep POS'
  s.description  = 'Stream Rep records to a Singer target, such as Stitch'
  s.authors      = ['Joe Lind']
  s.email        = 'joelind@gmail.com'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/Follain/tap-rep'

  s.files        = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', '*.md']
  s.require_path = 'lib'
  s.executables  = ['tap-rep']

  s.add_runtime_dependency 'concurrent-ruby', '~> 1.0', '>= 1.0.2'
  s.add_runtime_dependency 'faraday', '~> 0.12', '>= 0.12.1'
  s.add_runtime_dependency 'faraday_middleware', '~> 0.11', '>= 0.11.0.1'
end
