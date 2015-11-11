# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tdl/version'

# DEBT: The patch version is not resetting correctly

SPEC_FOLDER = File.expand_path('../features/spec',__FILE__).to_s
puts "Spec folder is: #{SPEC_FOLDER}"
MAJOR_MINOR_VERSION = `git --git-dir #{SPEC_FOLDER}/.git describe --all | cut -d '/' -f 2 | tr -d 'v'`.strip
VERSION = "#{MAJOR_MINOR_VERSION}.#{TDL::CURRENT_PATCH_VERSION}"

Gem::Specification.new do |spec|
  spec.name          = 'tdl-client-ruby'
  spec.version       = VERSION
  spec.authors       = ['Julian Ghionoiu']
  spec.email         = ['iulian.ghionoiu@gmail.com']

  spec.summary       = %q{A client to connect to the central kata server.}
  spec.description   = %q{A ruby client to connect to the kata server}
  spec.homepage      = 'https://github.com/julianghionoiu/tdl-client-ruby'
  spec.license       = 'GPL-3.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'stomp', '1.3.4'
  spec.add_runtime_dependency 'logging', '2.0.0'


  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '5.4.1'
  spec.add_development_dependency 'minitest-reporters', '~> 1.0', '>= 1.0.19'
  spec.add_development_dependency 'simplecov', '~>0.10.0'
  spec.add_development_dependency 'coveralls', '~>0.8.2'
  spec.add_development_dependency 'json', '~> 1.8', '~>1.8.3'
  spec.add_development_dependency 'cucumber', '>= 2.0.0', '<2.1.0'
  spec.add_development_dependency 'debase', '~>0.1.4'
end
