# The SandboxInput provides a flexible execution environment for data ingestion and transformation without
# the need to recompile Heka. Like all other sandboxes it needs to implement a process_message function.
# However, it doesn't have to return until shutdown. If you would like to implement a polling interface process_message
# can return zero when complete and it will be called again the next time TickerInterval fires
# (if ticker_interval was set to zero it would simply exit after running once).
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
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

define heka::outputs::sandboxoutput (
  $ensure                       = 'present',
  # Common Sandbox Parameters
  $script_type       = 'lua',
  $filename,
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  $config            = undef,
) {
  # Common Sandbox Parameters
  validate_string($filename)
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }

  $plugin_name = "sandboxinput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/sandboxoutput.toml.erb"),
  }
}
