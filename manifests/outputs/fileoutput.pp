# Writes message data out to a file system.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
### Common Output Parameters::  Check heka::outputs::tcpoutput for the description
#
### File Parameters
#
# $path::                        Full path to the output file. If date rotation is in use, then the output file path can support
#                                strftime syntax to embed timestamps in the file path: http://strftime.org
#
# $perm::                        File permission for writing. A string of the octal digit representation. Defaults to "644".
#
# $folder_perm::                 Permissions to apply to directories created for FileOutput's parent directory if it doesn't exist.
#                                Must be a string representation of an octal integer. Defaults to "700".
#
# $flush_interval::              Interval at which accumulated file data should be written to disk, in milliseconds (default 1000,
#                                i.e. 1 second).
#                                Set to 0 to disable.
#
# $flush_count::                 Number of messages to accumulate until file data should be written to disk (default 1, minimum 1).
#
# $flush_operator::              Operator describing how the two parameters "flush_interval" and "flush_count" are combined.
#                                Allowed values are "AND" or "OR" (default is "AND").
#
# $use_framing::                 Specifies whether or not the encoded data sent out over the TCP connection should be delimited by
#                                Heka's Stream Framing.
#                                Defaults to true if a ProtobufEncoder is used, false otherwise.
#
# $rotation_interval::           Interval at which the output file should be rotated, in hours. Only the following values are
#                                allowed: 0, 1, 4, 12, 24 (set to 0 to disable). The files will be named relative to midnight
#                                of the day.
#                                Defaults to 0, i.e. disabled.
#
define heka::outputs::fileoutput (
  $ensure              = 'present',
  # Common Output Parameters
  $message_matcher     = undef,
  $message_signer      = undef,
  $ticker_interval     = 5,
  $encoder             = undef,
  $use_framing         = undef,
  $can_exit            = undef,
  $use_buffering       = undef,
  # Buffering
  $max_file_size       = undef,
  $max_buffer_size     = undef,
  $full_action         = undef,
  $cursor_update_count = undef,
  # File Output Parameters
  $path,
  $perm                = '644',
  $folder_perm         = '700',
  $flush_interval      = 1000,
  $flush_count         = 1,
  $flush_operator      = 'AND',
  $rotation_interval   = 0,
) {
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
  # File Output Parameters
  validate_string($path)
  validate_string($perm)
  validate_string($folder_perm)
  validate_integer($flush_interval)
  validate_integer($flush_count)
  validate_string($flush_operator)
  validate_integer($rotation_interval)

  $plugin_name = "fileoutput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/fileoutput.toml.erb"),
  }
}
