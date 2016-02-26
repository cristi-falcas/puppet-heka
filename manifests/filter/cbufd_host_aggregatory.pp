# Collects the circular buffer delta output from multiple instances of an upstream sandbox filter
# (the filters should all be the same version at least with respect to their cbuf output).
# Each column from the source circular buffer will become its own graph. i.e., 'Error Count' will
# become a graph with each host being represented in a column.
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
### CBuf Delta Aggregator By Hostname Parameters
#
# $max_hosts::                    Pre-allocates the number of host columns in the graph(s). If the number of
#                                 active hosts exceed this value, the plugin will terminate.
#                                 Type: uint
#
# $rows::                         The number of rows to keep from the original circular buffer. Storing all the data
#                                 from all the hosts is not practical since you will most likely run into memory and
#                                 output size restrictions (adjust the view down as necessary).
#                                 Type: uint
#
# $host_expiration::              The amount of time a host has to be inactive before it can be replaced by a new host.
#                                 Default 120
#                                 Type: uint
#
# $preservation_version::         If preserve_data = true is set in the SandboxFilter configuration, then this value should
#                                 be incremented every time the max_hosts or rows configuration is changed to prevent the plugin
#                                 from failing to start during data restoration.
#                                 Default 0
#                                 Type: uint
#
define heka::filter::cbufd_host_aggregatory (
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
  # CBuf Delta Aggregator By Hostname Parameters
  # lint:ignore:parameter_order
  $max_hosts,
  $rows,
  # lint:endignore
  $host_expiration      = 120,
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
  # CBuf Delta Aggregator By Hostname Parameters
  validate_integer($max_hosts, $rows, $host_expiration)
  if $preservation_version { validate_integer($preservation_version) }

  $script_type = 'lua'
  $filename = 'lua_filters/cbufd_host_aggregatory.lua'
  $config = {
    'max_hosts'            => $max_hosts,
    'rows'                 => $rows,
    'host_expiration'      => $host_expiration,
    'preservation_version' => $preservation_version,
  }

  $full_name = "cbufd_aggregator_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/sandboxfilter.toml.erb"),
  }
}
