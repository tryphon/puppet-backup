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

  cron { 'backup-models':
    command  => '/usr/local/sbin/backup-models',
    user     => root,
    hour     => 2 + fqdn_rand(4,'backup_cron_hour'),
    minute   => 15 * fqdn_rand(4,'backup_cron_minute'),
  }

  file { "/etc/cron.daily/backup-models":
    ensure => absent
  }

  file { "/etc/logrotate.d/backup":
    source => "puppet:///backup/logrotate",
    mode => 644
  }

   file { "/etc/backup/defaults.rb":
     source => ["puppet:///files/backup/defaults.rb", "puppet:///backup/defaults.rb"],
     mode => 600
   }

  include ruby::gems
  ruby::gem { backup: ensure => "3.0.25" }
  ruby::gem { net-sftp: }

  include ruby::gem::fog::dependencies
  ruby::gem { fog: ensure => "1.4.0" } # for S3 support
  ruby::gem { s3sync: }
  ruby::gem { parallel: ensure => "0.5.12" }

  ruby::gem { mail: ensure => "2.4.0" }

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
