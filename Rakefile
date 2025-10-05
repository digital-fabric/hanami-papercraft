# frozen_string_literal: true

task :default => :test
task :test do
  exec 'ruby test/run.rb'
end

task :release do
  require_relative './lib/papercraft_view_version'
  version = Hanami::PAPERCRAFT_VIEW_VERSION

  puts 'Building hanami-papercraft...'
  `gem build hanami-papercraft.gemspec`

  puts "Pushing hanami-papercraft #{version}..."
  `gem push hanami-papercraft-#{version}.gem`

  puts "Cleaning up..."
  `rm *.gem`
end
