define backup::model($source = "", $content = false) {

  if $content {
    file { "/etc/backup/models/$name.rb":
      content => $content,
      mode    => '0600',
      require => Class['backup']
    }
  } else {
    $real_source = $source ? {
      "" => ["puppet:///files/$name/backup.rb", "puppet:///modules/$name/backup.rb"],
      default => $source
    }
    file { "/etc/backup/models/$name.rb":
      source => $real_source,
      mode   => '0600',
      require => Class['backup']
    }
  }
}
