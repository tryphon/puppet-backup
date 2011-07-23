Backup::Model.new(:"git-<%= name %>", 'Git <%= name %>') do
  archive :git do |archive|
    archive.add '/srv/git/<%= name %>'
  end

  eval(IO.read('/etc/backup/global.rb'))
end
