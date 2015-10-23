Gem::Specification.new do |s|
  s.name = 'task-trooper'
  s.version = '1.0.1'
  s.date = '2015-10-22'
  s.summary = "Task Trooper"
  s.description = "Simple command line based task manager"
  s.authors = [ "Ricardo Corrieri" ]
  s.email = 'rcorrieri@enova.com'
  s.files << 'lib/task-trooper.rb'
  s.license = 'MIT'

  ['commander', 'sqlite3', 'sequel'].each do |dep|
    s.add_dependency dep
  end
end
