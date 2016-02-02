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
# $decoder::                     Decoder to be used by the input. This should refer to the name of a registered
#                                decoder plugin configuration. If supplied, messages will be decoded before being
#                                passed on to the router when the InputRunner's Deliver method is called.
#
# $synchronous_decode::          If synchronous_decode is false, then any specified decoder plugin will be
#                                run by a DecoderRunner in its own goroutine and messages will be passed in
#                                to the decoder over a channel, freeing the input to start processing the
#                                next chunk of incoming or available data. If true, then any decoding will
#                                happen synchronously and message delivery will not return control to the
#                                input until after decoding has completed. Defaults to false.
#
# $send_decode_failures::        If false, then if an attempt to decode a message fails then Heka will log
#                                an error message and then drop the message. If true, then in addition to
#                                logging an error message, decode failure will cause the original, undecoded
#                                message to be tagged with a decode_failure field (set to true) and delivered
#                                to the router for possible further processing.
#
# $can_exit::                    If false, the input plugin exiting will trigger a Heka shutdown. If set to true,
#                                Heka will continue processing other plugins. Defaults to false on most inputs.
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
