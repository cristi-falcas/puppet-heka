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
    include ::heka::logrotate
  }
}
