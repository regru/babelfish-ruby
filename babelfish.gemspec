GEM_ROOT = File.dirname(__FILE__).freeze  unless defined?(GEM_ROOT)

lib_path = File.expand_path('lib', GEM_ROOT)
$LOAD_PATH.unshift(lib_path)  unless $LOAD_PATH.include? lib_path

require 'babelfish/version'

Gem::Specification.new do |s|
  s.name     = "babelfish-ruby"
  s.version  = Babelfish::VERSION.dup
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary  = "Babelfish syntax internationalization module."
  s.email    = "akzhan.abdulin@gmail.com"
  s.homepage = "http://regru.github.io/babelfish-ruby/"
  s.description = "Human friendly i18n in both JavaScript, Ruby, Perl whatever."
  s.has_rdoc = true
  s.author  = "Akzhan Abdulin"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency('rake', ['~> 0.8',  '!= 0.9.0'])
  s.add_development_dependency('yard', '~> 0.8.7')
  s.add_development_dependency('redcarpet', '~> 3.0')
  s.add_development_dependency(%q<rspec>, [">= 3.0"])
end

