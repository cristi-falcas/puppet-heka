# Takes care of starting heka service
class heka::service {

  case $heka::service_provider {
    'init': {
      # File resource for /etc/init/heka.conf, the Upstart config file:
      file { '/etc/init.d/heka':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/${heka::service_template}"),
        before  => Service['heka'],
        notify  => Service['heka'],
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
        before  => Service['heka'],
        notify  => Service['heka'],
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

  service { 'heka':
    ensure => running,
    enable => true,
  }
}
