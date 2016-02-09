# Specialized output plugin that listens for certain Heka reporting message types and generates JSON data
# which is made available via HTTP for use in web based dashboards and health reports.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
### Common Output Parameters::  Check heka::outputs::tcpoutput for the description
#
### Dashboar Parameters
#
# $use_buffering::               If true, all messages delivered to this output will be buffered to disk before delivery, preventing back
#                                pressure and allowing retries in cases of message processing failure. Defaults to false, unless otherwise
#                                specified by the individual output's documentation.
#
# $buffering::                   A sub-section that specifies the settings to be used for the buffering behavior. This will only have any
#                                impact if use_buffering is set to true
#
# $host::                        An IP address on which we will serve output via HTTP. Defaults to "0.0.0.0".
#
# $port::                        An IP port on which we will serve output via HTTP. Defaults to "4352".
#
# $working_directory::           File system directory into which the plugin will write data files and from which it will serve
#                                HTTP. The Heka process must have read / write access to this directory. Relative paths will be
#                                evaluated relative to the Heka base directory. Defaults to $(BASE_DIR)/dashboard.
#
# $static_directory::            File system directory where the Heka dashboard source code can be found. The Heka process must have
#                                read access to this directory. Relative paths will be evaluated relative to the Heka base
#                                directory.
#                                Defaults to ${SHARE_DIR}/dasher.
#
# $headers::                     It is possible to inject arbitrary HTTP headers into each outgoing response by adding a TOML
#                                subsection entitled "headers" to you HttpOutput config section. All entries in the subsection
#                                must be a list of string values.
#
define heka::outputs::dashboardoutput (
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
  # Dashboard Output
  $host                = '0.0.0.0',
  $port                = 4352,
  $working_directory   = undef,
  $static_directory    = undef,
  $headers             = undef,
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
  # Dashboard Output
  validate_string($host)
  validate_integer($port)
  if $working_directory { validate_string($working_directory) }
  if $static_directory { validate_string($static_directory) }
  if $headers { validate_string($headers) }

  $plugin_name = "dashboard_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/dashboard.toml.erb"),
  }
}
