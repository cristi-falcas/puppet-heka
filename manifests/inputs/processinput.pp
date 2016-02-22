# Executes one or more external programs on an interval, creating messages from the output. Supports a chain
# of commands, where stdout from each process will be piped into the stdin for the next process in the chain.
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
# $command::                      The command is a structure that contains the full path to the binary, command line
#                                 arguments, optional enviroment variables and an optional working directory (see below).
#                                 Type: map[uint]cmd_config
#                                  cmd_config structure:
#                                  - bin: The full path to the binary that will be executed.
#                                  - args: Command line arguments to pass into the executable.
#                                  - env: Used to set environment variables before command is run.
#                                         Default is nil, which uses the heka process's environment.
#                                  - directory: Used to set the working directory of Bin Default is "",
#                                               which uses the heka process's working directory.
#
# $ticker_interval::              The number of seconds to wait between each run of command. Defaults to 15.
#                                 A ticker_interval of 0 indicates that the command is run only once, and should only be
#                                 used for long running processes that do not exit.
#                                 Type: uint
#
# $immediate_start::              If true, heka starts process immediately instead of waiting for first interval
#                                 defined by ticker_interval to pass. Defaults to false.
#                                 Type: bool
#
# $stdout::                       If true, for each run of the process chain a message will be generated with the last
#                                 command in the chain's stdout as the payload. Defaults to true.
#                                 Type: bool
#
# $stderr::                       If true, for each run of the process chain a message will be generated with the last
#                                 command in the chain's stderr as the payload. Defaults to false.
#                                 Type: bool
#
# $timeout::                      Timeout in seconds before any one of the commands in the chain is terminated.
#                                 Type: uint
#
define heka::inputs::processinput (
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
  $command              = undef,
  $ticker_interval      = undef,
  $immediate_start      = undef,
  $stdout               = undef,
  $stderr               = undef,
  $timeout              = undef,
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
  if $immediate_start { validate_bool($immediate_start) }
  if $stdout { validate_bool($stdout) }
  if $stderr { validate_bool($stderr) }
  if $timeout { validate_integer($timeout) }

  validate_array($command)
  validate_hash($command[0])

  $full_name = "processinput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/processinput.toml.erb"),
  }
}
