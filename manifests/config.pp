# configures heka
class heka::config {

  file { '/etc/heka':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Service['heka'],
  }

  file { '/etc/heka/heka.toml':
    ensure  => file,
    content => template("${module_name}/heka.toml.erb"),
    notify  => Service['heka'],
  }

  if $heka::logrotate {
    include heka::logrotate
  }

  case $::osfamily {
    'RedHat' : {
      case $::operatingsystemmajrelease {
        '6' : {
          # File resource for /etc/init/heka.conf, the Upstart config file:
          file { '/etc/init.d/heka':
            ensure  => 'file',
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            content => template('heka/heka.sh'),
            notify  => Service['heka'],
          }
        }
        '7' : {
          file { '/usr/lib/systemd/system/heka.service':
            ensure  => present,
            force   => true,
            content => template("heka/heka.service"),
            notify  => Service['heka'],
          } ~>
          exec { 'heka-systemd-reload':
            command     => '/usr/bin/systemctl daemon-reload',
            refreshonly => true,
          }
        }
      }
    }
    default            : {
      fail("${::operatingsystem} is not a supported operating system!")
    }
  }
}
