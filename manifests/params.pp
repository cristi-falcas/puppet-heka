# Default parameters for heka module
class heka::params {
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
  $sample_denominator = 1000
  $pid_file = undef
  $hostname = undef
  $max_message_size = 65536
  $logrotate = true
}
