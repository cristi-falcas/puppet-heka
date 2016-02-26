# Graphs HTTP status codes using the numeric Fields[status] variable collected from web server access logs.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Filter Parameters::    Check heka::filter::sandboxfilter for the description
#
### Buffering::                   Check heka::filter::sandboxfilter for the description
#
### Common Sandbox Parameters::   Check heka::filter::sandboxfilter for the description
#
### HTTP Status Graph Parameters
#
# $sec_per_row::                  Sets the size of each bucket (resolution in seconds) in the sliding window.
#                                 Default 60
#                                 Type: uint
#
# $rows::                         Sets the size of the sliding window i.e., 1440 rows representing 60 seconds per
#                                 row is a 24 sliding hour window with 1 minute resolution.
#                                 Default 1440
#                                 Type: uint
#
# $alert_throttle::               Sets the throttle for the anomaly alert, in seconds.
#                                 Default 3600
#                                 Type: uint
#
# $preservation_version::         If preserve_data = true is set in the SandboxFilter configuration, then this value
#                                 should be incremented every time the sec_per_row or rows configuration is changed to
#                                 prevent the plugin from failing to start during data restoration.
#                                 Default 0
#                                 Type: uint
#
define heka::filter::httpstatus (
  $ensure               = 'present',
  # Common Filter Parameters
  $message_matcher      = undef,
  $message_signer       = undef,
  $ticker_interval      = undef,
  $can_exit             = undef,
  $use_buffering        = undef,
  # Buffering
  $max_file_size        = undef,
  $max_buffer_size      = undef,
  $full_action          = undef,
  $cursor_update_count  = undef,
  # Common Sandbox Parameters
  $preserve_data        = undef,
  $memory_limit         = undef,
  $instruction_limit    = undef,
  $output_limit         = undef,
  $module_directory     = undef,
  # HTTP Status Graph Parameters
  $sec_per_row          = 60,
  $rows                 = 1440,
  $alert_throttle       = 360,
  $preservation_version = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Filter Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $can_exit { validate_bool($can_exit) }
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # HTTP Status Graph Parameters
  validate_integer($sec_per_row, $rows, $alert_throttle)
  if $preservation_version { validate_integer($preservation_version) }

  $script_type = 'lua'
  $filename = 'lua_filters/http_status.lua'
  $config = {
    'sec_per_row'          => $sec_per_row,
    'rows'                 => $rows,
    'alert_throttle'       => $alert_throttle,
    'preservation_version' => $preservation_version,
  }

  $full_name = "httpstatus_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/sandboxfilter.toml.erb"),
  }
}
