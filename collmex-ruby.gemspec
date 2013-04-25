Gem::Specification.new do |s|
  s.name        = 'collmex-ruby'
  s.version     = '0.1.0'
  s.date        = '2012-07-29'
  s.summary     = "A ruby api lib for collmex"
  s.description = "A lib written in ruby that talks to the german accounting software collmex."
  s.authors     = ["Roman Lehnert"]
  s.email       = 'roman.lehnert@googlemail.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/romanlehnert/collmex-ruby'
  s.license     = "MIT"
  s.add_development_dependency 'rspec', '~> 2.5'
  s.test_files  = Dir.glob("{spec,test}/**/*.rb")
end
