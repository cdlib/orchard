require 'rubygems'
require 'rake'

#-----------------------------------------------------
# Orchard Rakefile (Much emulated from mojombo/jekyll)
#-----------------------------------------------------

# HELPERS
#_________________________________
def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  line = File.read("lib/#{name}/version.rb")[/^\s*VERSION\s*=\s*.*/]
  line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
end

# TASKS
#__________________________________
task :default => [:test]

# Testing
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/test_*.rb'
  test.verbose = true
end

# Generate rdoc
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Update rdoc Rubyforge
rubyforge_user = 'scollett'
rubyforge_project = 'orchard'
rubyforge_path = "/var/www/gforge-projects/#{rubyforge_project}/"
desc 'Upload documentation to RubyForge.'
task 'upload-docs' => ['rdoc'] do
     sh "scp -r rdoc/* " +
         "#{rubyforge_user}@rubyforge.org:#{rubyforge_path}"
end