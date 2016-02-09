# Executes one or more external programs on an interval, creating messages from the output. Supports a chain
# of commands, where stdout from each process will be piped into the stdin for the next process in the chain.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $splitter::                    Splitter to be used by the input. This should refer to the name of a
#                                registered splitter plugin configuration. It specifies how the input
#                                should split the incoming data stream into individual records prior
#                                to decoding and/or injection to the router. Typically defaults to "NullSplitter",
#                                although certain inputs override this with a different default value.
#
### Common Input Parameters::   Check heka::inputs::tcpinput for the description
#
### Process Input Parameters
#
# $command::                     The command is a structure that contains the full path to the binary, command line
#                                arguments, optional enviroment variables and an optional working directory (see below).
#
# $ticker_interval::             The number of seconds to wait between each run of command. Defaults to 15.
#                                A ticker_interval of 0 indicates that the command is run only once, and should only be
#                                used for long running processes that do not exit.
#
# $immediate_start::             If true, heka starts process immediately instead of waiting for first interval
#                                defined by ticker_interval to pass. Defaults to false.
#
# $stdout::                      If true, for each run of the process chain a message will be generated with the last
#                                command in the chain's stdout as the payload. Defaults to true.
#
# $stderr::                      If true, for each run of the process chain a message will be generated with the last
#                                command in the chain's stderr as the payload. Defaults to false.
#
# $timeout::                     Timeout in seconds before any one of the commands in the chain is terminated.
#
define heka::inputs::processinput (
  $ensure               = 'present',
  # Common Input Parameters
  $splitter             = 'TokenSplitter',
  $decoder              = undef,
  $synchronous_decode   = undef,
  $send_decode_failures = undef,
  $can_exit             = undef,
  $log_decode_failures  = true,
  # ProcessInput specific Parameters
  $command              = undef,
  $ticker_interval      = undef,
  $immediate_start      = undef,
  $stdout               = undef,
  $stderr               = undef,
  $timeout              = undef,
) {
  # Common Input Parameters
  if $splitter { validate_string($splitter) }
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # ProcessInput specific Parameters
  if $ticker_interval { validate_integer($ticker_interval) }
  if $immediate_start { validate_bool($immediate_start) }
  if $stdout { validate_bool($stdout) }
  if $stderr { validate_bool($stderr) }
  if $timeout { validate_integer($timeout) }

  validate_array($command)
  validate_hash($command[0])

  $plugin_name = "processinput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/processinput.toml.erb"),
  }
}
