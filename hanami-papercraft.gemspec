require_relative './lib/hanami/papercraft_view_version'

Gem::Specification.new do |s|
  s.name        = 'hanami-papercraft'
  s.version     = Hanami::PAPERCRAFT_VIEW_VERSION
  s.licenses    = ['MIT']
  s.summary     = 'Hanami-Papercraft: Papercraft views for Hanami'
  s.author      = 'Sharon Rosner'
  s.email       = 'sharon@noteflakes.com'
  s.files       = `git ls-files README.md CHANGELOG.md lib`.split
  s.homepage    = 'http://github.com/digital-fabric/hanami-papercraft'
  s.metadata    = {
    "homepage_uri" => "https://github.com/digital-fabric/hanami-papercraft",
    "changelog_uri" => "https://github.com/digital-fabric/hanami-papercraft/blob/master/CHANGELOG.md"
  }

  s.rdoc_options = ["--title", "Hanami-Papercraft", "--main", "README.md"]
  s.extra_rdoc_files = ["README.md", "papercraft.png"]
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 3.4'

  s.add_runtime_dependency      'hanami-view',          '~>2.2'
  s.add_runtime_dependency      'papercraft',           '~>2.17'

  s.add_development_dependency  'minitest',             '~>5.25.5'
end
