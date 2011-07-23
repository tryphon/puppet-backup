class backup {

  file { "/etc/backup": 
    ensure => directory
  }

  # Contains models managed by backup-models
  file { "/etc/backup/models": 
    ensure => directory
  }

  file { "/etc/backup/global.rb":
    source => "puppet:///files/backup/global.rb",
    mode => 600
  }

  file { "/usr/local/sbin/backup-models":
    source => "puppet:///backup/backup-models",
    mode => 755
  }

  file { "/etc/cron.daily/backup-models":
    ensure => "/usr/local/sbin/backup-models"
  }

  include ruby::gems
  ruby::gem { backup: }
  ruby::gem { net-sftp: }

  define model($source = "puppet:///files/$name/backup.rb", $content = false) {
    include backup
    
    if $content {
      file { "/etc/backup/models/$name.rb":
        content => $content,
        mode => 600
      } 
    } else {
      file { "/etc/backup/models/$name.rb":
        source => $source,
        mode => 600
      }
    }
  }

  define trac() {
    backup::model { "trac-$name":
      content => template("backup/trac.rb")
    }
  }

  define git() {
    backup::model { "git-$name":
      content => template("backup/git.rb")
    }
  }

}
