# The ProcessDirectoryInput periodically scans a filesystem directory looking for ProcessInput configuration files.
# The ProcessDirectoryInput will maintain a pool of running ProcessInputs based on the contents of this directory,
# refreshing the set of running inputs as needed with every rescan. This allows Heka administrators to manage a set
# of data collection processes for a running hekad server without restarting the server.
#
# Each ProcessDirectoryInput has a process_dir configuration setting, which is the root folder of the tree where scheduled
# jobs are defined. It should contain exactly one nested level of subfolders, named with ASCII numeric characters indicating
# the interval, in seconds, between each process run. These numeric folders must contain TOML files which specify the details
# regarding which processes to run.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Input Parameters::     Check heka::inputs::tcpinput for the description
#
### Configuring Restarting Behavior:: Check heka::inputs::amqpinput for the description
#
### Process Input Parameters
#
# $ticker_interval::              The number of seconds to wait between each run of command. Defaults to 15.
#                                 A ticker_interval of 0 indicates that the command is run only once, and should only be
#                                 used for long running processes that do not exit.
#                                 Type: int
#
# $process_dir::                  This is the root folder of the tree where the scheduled jobs are defined. Absolute paths will
#                                 be honored, relative paths will be computed relative to Heka's globally specified share_dir.
#                                 Defaults to "processes" (i.e. "$share_dir/processes").
#                                 Type: string
#
define heka::inputs::processdirectoryinput (
  $ensure               = 'present',
  # Common Input Parameters
  $decoder              = undef,
  $synchronous_decode   = undef,
  $send_decode_failures = undef,
  $can_exit             = undef,
  $splitter             = 'TokenSplitter',
  $log_decode_failures  = true,
  # Retries Parameters
  $retries                      = false,
  $retries_max_jitter           = '500ms',
  $retries_max_delay            = '30s',
  $retries_delay                = '250ms',
  $retries_max_retries          = -1,
  # ProcessInput specific Parameters
  $ticker_interval      = undef,
  $process_dir          = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Input Parameters
  if $splitter { validate_string($splitter) }
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # Retries Parameters
  if $retries { validate_bool($retries) }
  if $retries_max_jitter { validate_string($retries_max_jitter) }
  if $retries_max_delay { validate_string($retries_max_delay) }
  if $retries_delay { validate_string($retries_delay) }
  if $retries_max_retries { validate_integer($retries_max_retries) }
  # ProcessInput specific Parameters
  if $ticker_interval { validate_integer($ticker_interval) }
  if $process_dir { validate_string($process_dir) }

  $full_name = "processdirectoryinputt_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/processdirectoryinput.toml.erb"),
  }
}
