# Generates documentation for each unique message in a data stream. The output is a hierarchy of Logger, Type, EnvVersion,
# and a list of associated message field attributes including their counts (number in the brackets).
# This plugin is meant for data discovery/exploration and should not be left running on a production system.
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
define heka::filter::heka_message_schema (
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

  $script_type = 'lua'
  $filename = 'lua_filters/heka_message_schema.lua'

  $full_name = "heka_message_schema_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/sandboxfilter.toml.erb"),
  }
}
