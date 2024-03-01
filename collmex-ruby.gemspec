Gem::Specification.new do |s|
  s.name        = 'collmex-ruby'
  s.version     = '1.2.0'
  s.date        = '2024-03-01'
  s.summary     = "A ruby api lib for collmex"
  s.description = "A lib written in ruby that talks to the german accounting software collmex."
  s.authors     = ["Roman Lehnert"]
  s.email       = 'roman.lehnert@googlemail.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/romanlehnert/collmex-ruby'
  s.license     = "MIT"
  s.add_dependency 'csv'
  s.add_dependency 'base64'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'vcr'
  s.test_files  = Dir.glob("{spec,test}/**/*.rb")
end
