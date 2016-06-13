# Default parameters for heka module
class heka::params {
  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'OracleLinux': {
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $service_provider = 'systemd'
        $service_template = 'heka.systemd.service.erb'
      } else {
        $service_provider = 'init'
        $service_template = 'heka.init.redhat.erb'
      }
    }
    'Debian': {
      if versioncmp($::operatingsystemmajrelease, '8') >= 0 {
        $service_provider = 'systemd'
        $service_template = 'heka.systemd.service.erb'
      } else {
        $service_provider = 'init'
        $service_template = 'heka.init.debian.erb'
      }
    }
    'Ubuntu': {
      if versioncmp($::operatingsystemmajrelease, '15') >= 0 {
        $service_provider = 'systemd'
        $service_template = 'heka.systemd.service.erb'
      } else {
        $service_provider = 'init'
        $service_template = 'heka.init.debian.erb'
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $package_ensure = 'installed'
  $cpuprof = undef
  $max_message_loops = 4
  $max_process_inject = 1
  $max_process_duration = 100000
  $max_timer_inject = 10
  $max_pack_idle = undef
  $maxprocs = $::processorcount
  $memprof = undef
  $poolsize = 100
  $plugin_chansize = 30
  $base_dir = '/var/cache/hekad'
  $share_dir = '/usr/share/heka'
  $purge_conf_dir = true
  $sample_denominator = 1000
  $pid_file = undef
  $hostname = undef
  $max_message_size = 65536
  $logrotate = true

  $journald_forward_enable = false
}
