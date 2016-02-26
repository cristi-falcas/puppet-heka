# Collects the circular buffer delta output from multiple instances of an upstream sandbox filter
# (the filters should all be the same version at least with respect to their cbuf output).
# The purpose is to recreate the view at a larger scope in each level of the aggregation i.e.,
# host view -> datacenter view -> service level view.
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
### Circular Buffer Delta Aggregator Parameters
#
# $enable_delta::                 Specifies whether or not this aggregator should generate cbuf deltas.
#                                 Default false
#                                 Type: bool
#
# $preservation_version::         If preserve_data = true is set in the SandboxFilter configuration,
#                                 then this value should be incremented every time the enable_delta configuration is
#                                 changed to prevent the plugin from failing to start during data restoration.
#                                 Default 0
#                                 Type: uint
#
define heka::filter::cbufd_aggregator (
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
  # Circular Buffer Delta Aggregator Parameters
  $enable_delta         = false,
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
  # Circular Buffer Delta Aggregator Parameters
  validate_bool($enable_delta)
  if $preservation_version { validate_integer($preservation_version) }

  $script_type = 'lua'
  $filename = 'lua_filters/cbufd_aggregator.lua'
  $config = {
    'enable_delta'         => $enable_delta,
    'preservation_version' => $preservation_version,
  }

  $full_name = "cbufd_aggregator_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/sandboxfilter.toml.erb"),
  }
}
