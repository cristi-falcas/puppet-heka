# The SandboxOutput provides a flexible execution environment for data encoding and transmission without the need to recompile Heka. 
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Output Parameters::    Check heka::outputs::tcpoutput for the description
#                                 The common output configuration parameter 'encoder' is ignored since all
#                                 data transformation should happen in the plugin.
#
### Common Sandbox Parameters
#
# $script_type::                  The language the sandbox is written in. Currently the only valid option is 'lua' which is the
#                                 default.
#
# $filename::                     The path to the sandbox code; if specified as a relative path it will be appended to Heka's global
#                                 share_dir.
#
# $preserve_data::                True if the sandbox global data should be preserved/restored on plugin shutdown/startup.
#                                 When true this works in conjunction with a global Lua _PRESERVATION_VERSION variable which
#                                 is examined during restoration; if the previous version does not match the current version
#                                 the restoration will be aborted and the sandbox will start cleanly. _PRESERVATION_VERSION should
#                                 be incremented any time an incompatible change is made to the global data schema. If no version
#                                 is set the check will always succeed and a version of zero is assumed.
#
# $memory_limit::                 The number of bytes the sandbox is allowed to consume before being terminated (default 8MiB).
#
# $instruction_limit::            The number of instructions the sandbox is allowed to execute during the
#                                 process_message/timer_event functions before being terminated (default 1M).
#
# $output_limit::                 The number of bytes the sandbox output buffer can hold before being terminated (default 63KiB).
#                                 Warning: messages exceeding 64KiB will generate an error and be discarded by the standard output
#                                 plugins (File, TCP, UDP) since they exceed the maximum message size.
#
# $module_directory::             The directory where 'require' will attempt to load the external Lua modules from. Defaults to ${SHARE_DIR}/lua_modules.
#
# $config::                       A map of configuration variables available to the sandbox via read_config.
#                                 The map consists of a string key with: string, bool, int64, or float64 values.
#
### SandboxOutput Parameters
#
# $timer_event_on_shutdown::      True if the sandbox should have its timer_event function called on shutdown.
#                                 Type: bool
#
define heka::outputs::sandboxoutput (
  $ensure                  = 'present',
  # Common Output Parameters
  $message_matcher,
  $message_signer          = undef,
  $ticker_interval         = undef,
  $use_framing             = undef,
  $can_exit                = undef,
  $use_buffering           = undef,
  # Buffering
  $max_file_size           = undef,
  $max_buffer_size         = undef,
  $full_action             = undef,
  $cursor_update_count     = undef,
  # Common Sandbox Parameters
  $script_type             = 'lua',
  $filename,
  $preserve_data           = undef,
  $memory_limit            = undef,
  $instruction_limit       = undef,
  $output_limit            = undef,
  $module_directory        = undef,
  $config                  = undef,
  # SandboxOutput Parameters
  $timer_event_on_shutdown = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  $encoder = undef
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
  # Common Sandbox Parameters
  validate_string($filename)
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # SandboxOutput Parameters
  if $timer_event_on_shutdown { validate_bool($timer_event_on_shutdown) }

  $full_name = "sandboxoutput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/sandboxoutput.toml.erb"),
  }
}
