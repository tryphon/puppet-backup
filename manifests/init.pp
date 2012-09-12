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

  include ruby::gem::fog::dependencies
  ruby::gem { fog: } # for S3 support
  ruby::gem { s3sync: }

  define model($source = "", $content = false) {
    include backup

    if $content {
      file { "/etc/backup/models/$name.rb":
        content => $content,
        mode => 600
      } 
    } else {
      $real_source = $source ? {
        "" => ["puppet:///files/$name/backup.rb", "puppet:///$name/backup.rb"],
        default => $source
      }  
      file { "/etc/backup/models/$name.rb":
        source => $real_source,
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
