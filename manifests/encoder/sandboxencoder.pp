# The SandboxEncoder provides an isolated execution environment for converting messages into binary data without the need to
# recompile Heka.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
# $script_type::                  The language the sandbox is written in. Currently the only valid option is 'lua' which is the
#                                 default.
#                                 Type: string
#
# $filename::                     The path to the sandbox code; if specified as a relative path it will be appended to Heka's global
#                                 share_dir.
#                                 Type: string
#
# $preserve_data::                True if the sandbox global data should be preserved/restored on plugin shutdown/startup.
#                                 When true this works in conjunction with a global Lua _PRESERVATION_VERSION variable which
#                                 is examined during restoration; if the previous version does not match the current version
#                                 the restoration will be aborted and the sandbox will start cleanly. _PRESERVATION_VERSION should
#                                 be incremented any time an incompatible change is made to the global data schema. If no version
#                                 is set the check will always succeed and a version of zero is assumed.
#                                 Type: bool
#
# $memory_limit::                 The number of bytes the sandbox is allowed to consume before being terminated (default 8MiB).
#                                 Type: uint
#
# $instruction_limit::            The number of instructions the sandbox is allowed to execute during the
#                                 process_message/timer_event functions before being terminated (default 1M).
#                                 Type: uint
#
# $output_limit::                 The number of bytes the sandbox output buffer can hold before being terminated (default 63KiB).
#                                 Warning: messages exceeding 64KiB will generate an error and be discarded by the standard output
#                                 plugins (File, TCP, UDP) since they exceed the maximum message size.
#                                 Type: uint
#
# $module_directory::             The directory where 'require' will attempt to load the external Lua modules from. Defaults to ${SHARE_DIR}/lua_modules.
#                                 Type: string
#
# $config::                       A map of configuration variables available to the sandbox via read_config.
#                                 The map consists of a string key with: string, bool, int64, or float64 values.
#                                 Type: object
#
define heka::encoder::sandboxencoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  # lint:ignore:parameter_order
  $filename,
  # lint:endignore
  $script_type       = 'lua',
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  # encoder specific
  # lint:ignore:parameter_order
  $config,
  # lint:endignore
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  validate_string($filename)
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }

  $sandbox_type = 'SandboxEncoder'

  $full_name = "sandboxencoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
