Backup::Model.new(:"trac-<%= name %>", 'Trac <%= name %>') do
  archive :trac do |archive|
    archive.add '/var/lib/trac/<%= name %>'
  end

  eval(IO.read('/etc/backup/global.rb'))
end
