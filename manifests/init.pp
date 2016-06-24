# Class: heka
#
# This module manages heka
#
# === Parameters:
#
# $package_ensure::                       set package version to be installed or use 'installed'/'latest'
#
# $max_message_loops::                    The maximum number of times a message can be re-injected into the system.
#                                         This is used to prevent infinite message loops from filter to filter; the default is 4.
#
# $max_process_inject::                   The maximum number of messages that a sandbox filter's ProcessMessage
#                                         function can inject in a single call; the default is 1
#
# $max_process_duration::                 The maximum number of nanoseconds that a sandbox filter's ProcessMessage
#                                         function can consume in a single call before being terminated; the default is 100000
#
# $max_timer_inject::                     The maximum number of messages that a sandbox filter's TimerEvent function can inject
#                                         in a single call; the default is 10
#
# $max_pack_idle::                        A time duration string (e.x. "2s", "2m", "2h") indicating how long a message pack
#                                         can be 'idle' before its considered leaked by heka. If too many packs leak from a bug
#                                         in a filter or output then heka will eventually halt. This setting indicates when
#                                         that is considered to have occurred
#
# $maxprocs::                             Enable multi-core usage; the default is 1 core. More cores will generally increase message throughput.
#                                         Best performance is usually attained by setting this to 2 x (number of cores).
#                                         This assumes each core is hyper-threaded
#
# $poolsize::                             Specify the pool size of maximum messages that can exist. Default is 100
#
# $plugin_chansize::                      Specify the buffer size for the input channel for the various Heka plugins. Defaults to 30
#
# $base_dir::                             Base working directory Heka will use for persistent storage through process and server restarts.
#                                         The hekad process must have read and write access to this directory
#
# $share_dir::                            Root path of Heka's "share directory", where Heka will expect to find certain resources it needs to consume.
#                                         The hekad process should have read- only access to this directory
#
# $purge_conf_dir::                       Purge all files from Heka's "configuration directory". Defaults to true
#
# $sample_denominator::                   Specifies the denominator of the sample rate Heka will use when computing the time required
#                                         to perform certain operations, such as for the ProtobufDecoder to decode a message, or the router
#                                         to compare a message against a message matcher. Defaults to 1000,
#                                         i.e. duration will be calculated for one message out of 1000
#
# $pid_file::                             Optionally specify the location of a pidfile where the process id of the running hekad process will be written.
#                                         The hekad process must have read and write access to the parent directory (which is not automatically created).
#                                         On a successful exit the pidfile will be removed. If the path already exists the contained pid will be checked
#                                         for a running process. If one is found, the current process will exit with an error
#
# $hostname::                             Specifies the hostname to use whenever Heka is asked to provide the local host's hostname.
#                                         Defaults to whatever is provided by Go's os.Hostname() call
#
# $max_message_size::                     The maximum size (in bytes) of message can be sent during processing. Defaults to 64KiB
#
# $cpuprof::                              Turn on CPU profiling of hekad; output is logged to the output_file.
#
# $memprof::                              Enable memory profiling; output is logged to the output_file.
#
# $logrotate::                            Enable logrotating the heka log.
#
# $journald_forward_enable::              Enable the usage of the forward-journald binary to stand between heka and journald  (only for RHEL7).
#                                         Default: false
class heka (
  $package_ensure          = $heka::params::package_ensure,
  $max_message_loops       = $heka::params::max_message_loops,
  $max_process_inject      = $heka::params::max_process_inject,
  $max_process_duration    = $heka::params::max_process_duration,
  $max_timer_inject        = $heka::params::max_timer_inject,
  $max_pack_idle           = $heka::params::max_pack_idle,
  $maxprocs                = $heka::params::maxprocs,
  $poolsize                = $heka::params::poolsize,
  $plugin_chansize         = $heka::params::plugin_chansize,
  $base_dir                = $heka::params::base_dir,
  $share_dir               = $heka::params::share_dir,
  $purge_conf_dir          = $heka::params::purge_conf_dir,
  $sample_denominator      = $heka::params::sample_denominator,
  $pid_file                = $heka::params::pid_file,
  $hostname                = $heka::params::hostname,
  $max_message_size        = $heka::params::max_message_size,
  $cpuprof                 = $heka::params::cpuprof,
  $memprof                 = $heka::params::memprof,
  $logrotate               = $heka::params::logrotate,
  $journald_forward_enable = $heka::params::journald_forward_enable,
) inherits heka::params {
  contain '::heka::install'
  contain '::heka::config'
  contain '::heka::service'

  Class['heka::install'] ->
  Class['heka::config'] ~>
  Class['heka::service']
}
