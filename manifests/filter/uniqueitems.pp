# Counts the number of unique items per day e.g. active daily users by uid.
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
### Unique Items Parameters
#
# $message_variable::             The Heka message variable containing the item to be counted.
#                                 Type: string
#
# $graph_title::                        The graph title for the cbuf output.
#                                 Default "Estimated Unique Daily message_variable"
#                                 Type: string
#
# $enable_delta::                 Specifies whether or not this plugin should generate cbuf deltas.
#                                 Deltas should be enabled when sharding is used; see: Circular Buffer Delta Aggregator.
#                                 Default false
#                                 Type: bool
#
# $preservation_version::         If preserve_data = true is set in the SandboxFilter configuration, then this value should
#                                 be incremented every time the enable_delta configuration is changed to prevent the plugin
#                                 from failing to start during data restoration.
#                                 Default 0
#                                 Type: uint
#
define heka::filter::uniqueitems (
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
  # Unique Items Parameters
  $message_variable,
  $graph_title          = undef,
  $enable_delta         = undef,
  $preservation_version = undef
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
  # Unique Items Parameters
  validate_string($message_variable)
  if $graph_title { validate_string($graph_title) }
  if $enable_delta { validate_bool($enable_delta) }
  if $preservation_version { validate_integer($preservation_version) }

  $script_type = 'lua'
  $filename = 'lua_filters/unique_items.lua'
  $config = {
    'message_variable'     => $message_variable,
    'title'                => $graph_title,
    'enable_delta'         => $enable_delta,
    'preservation_version' => $preservation_version,
  }

  $full_name = "uniqueitems_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/sandboxfilter.toml.erb"),
  }
}
