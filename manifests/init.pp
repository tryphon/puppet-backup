class backup (
  $global_source = 'puppet:///modules/backup/global.rb',
  $global_content = '',
  $defaults_source = 'puppet:///modules/backup/defaults.rb',
  $gem_version = '4.4.0'){

  file { "/etc/backup":
    ensure => directory
  }

  # Contains models managed by backup-models
  file { "/etc/backup/models":
    ensure => directory
  }

  if $global_content == '' {
    file { "/etc/backup/global.rb":
      source => $global_source,
      mode   => '0600'
    }
  } else {
    file { "/etc/backup/global.rb":
      content => $global_content,
      mode    => '0600'
    }
  }
  

  file { "/usr/local/sbin/backup-models":
    source => "puppet:///modules/backup/backup-models",
    mode   => '0755'
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
    source => "puppet:///modules/backup/logrotate",
    mode   => '0644'
  }

   file { "/etc/backup/defaults.rb":
     source => $defaults_source,
     mode   => '0600'
   }

  include ruby::gems
  ruby::gem { backup: ensure => $gem_version }
  ruby::gem { 'facter': }
  package { [libxml2-dev, zlib1g-dev]: }
  package { libxslt1-dev: }

}
