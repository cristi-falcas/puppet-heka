# FilePollingInputs periodically read (unbuffered) the contents of a file specified, and creates a Heka message
# with the contents of the file as the payload.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
### Common Input Parameters::    Check heka::inputs::tcpinput for the description
#
### FilePolling Input Parameters
#
# $file_path::                   The absolute path to the file which the input should read.
#
# $ticker_interval::             How often, in seconds to input should read the contents of the file.
#
define heka::inputs::filepollinginput (
  $ensure                       = 'present',
  # Common Input Parameters
  $decoder                      = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit                     = undef,
  $splitter                     = undef,
  $log_decode_failures          = true,
  # FilePolling Input
  $file_path,
  $ticker_interval,
) {
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $splitter { validate_string($splitter) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # FilePolling Input
  validate_string($file_path)
  validate_integer($ticker_interval)

  $plugin_name = "filepollinginput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/filepollinginput.toml.erb"),
  }
}
