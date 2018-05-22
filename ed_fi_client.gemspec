
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ed_fi/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'ed_fi_client'
  spec.version       = EdFi::Client::VERSION
  spec.authors       = ['Nestor Custodio']
  spec.email         = ['sakimorix@gmail.com']

  spec.summary       = 'A simple API wrapper for Ed-Fi ODS access.'
  spec.homepage      = 'https://www.github.com/nestor-custodio/ed_fi_client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'pry-byebug', '~> 3.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.3'

  spec.add_dependency 'activesupport', '~> 5.2.0'
  spec.add_dependency 'crapi', '~> 0.1'
end
