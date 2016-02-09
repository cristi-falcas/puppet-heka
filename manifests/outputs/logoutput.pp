# Logs messages to stdout using Go's log package.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
### Common Output Parameters::   Check heka::outputs::tcpoutput for the description
#
define heka::outputs::logoutput (
  $ensure          = 'present',
  # Common Output Parameters
  $message_matcher = undef,
  $message_signer  = undef,
  $ticker_interval = 5,
  $encoder         = undef,
  $use_framing     = undef,
  $can_exit        = undef,
  $use_buffering   = undef,
  # Buffering
  $max_file_size                = undef,
  $max_buffer_size              = undef,
  $full_action                  = undef,
  $cursor_update_count          = undef,
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

  $plugin_name = "logoutput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/logoutput.toml.erb"),
  }
}
