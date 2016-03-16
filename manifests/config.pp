# configures heka
class heka::config {
  case $heka::service_provider {
    'init': {
      # File resource for /etc/init/heka.conf, the Upstart config file:
      file { '/etc/init.d/heka':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/${heka::service_template}"),
      }
    }
    'systemd': {
      file { '/etc/init.d/heka':
        ensure => 'absent',
      } ~>
      file { '/lib/systemd/system/heka.service':
        ensure  => 'file',
        force   => true,
        content => template("${module_name}/${heka::service_template}"),
      } ~>
      exec { 'heka-systemd-reload':
        command     => 'systemctl daemon-reload',
        path        => ['/bin', '/usr/bin'],
        refreshonly => true,
      }
    }
    default: {
      fail("Unknown service provider ${$heka::service_provider}")
    }
  }

  file { '/etc/heka':
    ensure  => directory,
    recurse => true,
    purge   => $heka:purge_conf_dir,
    force   => true,
  }

  file { '/etc/heka/heka.toml':
    ensure  => file,
    content => template("${module_name}/heka.toml.erb"),
  }

  if $heka::logrotate {
    include ::heka::logrotate
  }
}
