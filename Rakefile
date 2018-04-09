require './app'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['tests/test_file.rb']
end
