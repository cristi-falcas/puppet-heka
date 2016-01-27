# The SandboxInput provides a flexible execution environment for data ingestion and transformation without
# the need to recompile Heka. Like all other sandboxes it needs to implement a process_message function.
# However, it doesn't have to return until shutdown. If you would like to implement a polling interface process_message
# can return zero when complete and it will be called again the next time TickerInterval fires
# (if ticker_interval was set to zero it would simply exit after running once).
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $message_matcher::             Boolean expression, when evaluated to true passes the message to the filter for processing.
#                                Defaults to matching nothing
#
# $message_signer::              The name of the message signer. If specified only messages with this signer are passed to the
#                                filter for processing.
#
# $ticker_interval::             Frequency (in seconds) that a timer event will be sent to the filter. Defaults to not sending timer
#                                events.
#
# $encoder::                     Encoder to be used by the output. This should refer to the name of an encoder plugin section that
#                                is specified elsewhere in the TOML configuration.
#                                Messages can be encoded using the specified encoder by calling the OutputRunner's Encode() method.
#
# $use_framing::                 Specifies whether or not Heka's Stream Framing should be applied to the binary data returned from
#                                the OutputRunner's Encode() method.
#
# $can_exit::                    Whether or not this plugin can exit without causing Heka to shutdown. Defaults to false.
#
# $script_type::                 The language the sandbox is written in. Currently the only valid option is 'lua' which is the
#                                default.
#
# $filename::                    The path to the sandbox code; if specified as a relative path it will be appended to Heka's global
#                                share_dir.
#
# $preserve_data::               True if the sandbox global data should be preserved/restored on plugin shutdown/startup.
#                                When true this works in conjunction with a global Lua _PRESERVATION_VERSION variable which
#                                is examined during restoration; if the previous version does not match the current version
#                                the restoration will be aborted and the sandbox will start cleanly. _PRESERVATION_VERSION should
#                                be incremented any time an incompatible change is made to the global data schema. If no version
#                                is set the check will always succeed and a version of zero is assumed.
#
# $memory_limit::                The number of bytes the sandbox is allowed to consume before being terminated (default 8MiB).
#
# $instruction_limit::           The number of instructions the sandbox is allowed to execute during the
#                                process_message/timer_event functions before being terminated (default 1M).
#
# $output_limit::                The number of bytes the sandbox output buffer can hold before being terminated (default 63KiB).
#                                Warning: messages exceeding 64KiB will generate an error and be discarded by the standard output
#                                plugins (File, TCP, UDP) since they exceed the maximum message size.
#
# $module_directory::            The directory where 'require' will attempt to load the external Lua modules from. Defaults to ${SHARE_DIR}/lua_modules.
#
# $config::                      A map of configuration variables available to the sandbox via read_config.
#                                The map consists of a string key with: string, bool, int64, or float64 values.
#

define heka::inputs::sandboxinput (
  $ensure            = 'present',
  # Common Output Parameters
  $message_matcher   = undef,
  $message_signer    = undef,
  $ticker_interval   = undef,
  $use_framing       = undef,
  $can_exit          = undef,
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
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
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
    content => template("${module_name}/plugin/sandboxinput.toml.erb"),
  }
}
