# The SandboxManagerFilter provides dynamic control (start/stop) of sandbox filters in a secure manner without
# stopping the Heka daemon. Commands are sent to a SandboxManagerFilter using a signed Heka message. The intent
# is to have one manager per access control group each with their own message signing key. Users in each group can
# submit a signed control message to manage any filters running under the associated manager. A signed message is
# not an enforced requirement but it is highly recommended in order to restrict access to this functionality.
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
### SandboxManagerFilter Parameters
#
# $working_directory::            The directory where the filter configurations, code, and states are preserved. The directory
#                                 can be unique or shared between sandbox managers since the filter names are unique per manager.
#                                 Defaults to a directory in ${BASE_DIR}/sbxmgrs with a name generated from the plugin name.
#                                 Type: string
#
# $module_directory::             The directory where 'require' will attempt to load the external Lua modules from.
#                                 Defaults to ${SHARE_DIR}/lua_modules.
#                                 Type: string
#
# $max_filters::                  The maximum number of filters this manager can run.
#                                 Type: uint
#
# $memory_limit::                 The number of bytes managed sandboxes are allowed to consume before being terminated
#                                 Default 8MiB.
#                                 Type: uint
#
# $instruction_limit::            The number of instructions managed sandboxes are allowed to execute during the process_message/timer_event
#                                 functions before being terminated
#                                 Default 1M.
#                                 Type: uint
#
# $output_limit::                 The number of bytes managed sandbox output buffers can hold before being terminated.
#                                 Warning: messages exceeding 64KiB will generate an error and be discarded by the standard output plugins
#                                 (File, TCP, UDP) since they exceed the maximum message size.
#                                 Default 63KiB
#                                 Type: uint
#
define heka::filter::sandboxmanagerfilter (
  $ensure              = 'present',
  # Common Filter Parameters
  $message_matcher     = undef,
  $message_signer      = undef,
  $ticker_interval     = undef,
  $can_exit            = undef,
  $use_buffering       = undef,
  # Buffering
  $max_file_size       = undef,
  $max_buffer_size     = undef,
  $full_action         = undef,
  $cursor_update_count = undef,
  # SandboxManagerFilter Parameters
  $working_directory   = undef,
  $module_directory    = undef,
  # lint:ignore:parameter_order
  $max_filters,
  # lint:endignore
  $memory_limit        = undef,
  $instruction_limit   = undef,
  $output_limit        = undef,
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
  # SandboxManagerFilter Parameters
  if $working_directory { validate_string($working_directory) }
  if $module_directory { validate_string($module_directory) }
  validate_integer($max_filters)
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }

  $full_name = "sandboxmanagerfilter_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/sandboxmanagerfilter.toml.erb"),
  }
}
