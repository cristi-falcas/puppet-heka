# Class: heka
#
# This module manages heka
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class heka (
  $package_ensure       = $heka::params::package_ensure,
  $cpuprof              = $heka::params::cpuprof,
  $max_message_loops    = $heka::params::max_message_loops,
  $max_process_inject   = $heka::params::max_process_inject,
  $max_process_duration = $heka::params::max_process_duration,
  $max_timer_inject     = $heka::params::max_timer_inject,
  $max_pack_idle        = $heka::params::max_pack_idle,
  $maxprocs             = $heka::params::maxprocs,
  $memprof              = $heka::params::memprof,
  $poolsize             = $heka::params::poolsize,
  $plugin_chansize      = $heka::params::plugin_chansize,
  $base_dir             = $heka::params::base_dir,
  $share_dir            = $heka::params::share_dir,
  $sample_denominator   = $heka::params::sample_denominator,
  $pid_file             = $heka::params::pid_file,
  $hostname             = $heka::params::hostname,
  $max_message_size     = $heka::params::max_message_size,
) inherits heka::params {
  contain heka::install
  contain heka::config
  contain heka::service

  Class['heka::install'] ->
  Class['heka::config'] ~>
  Class['heka::service']
}
