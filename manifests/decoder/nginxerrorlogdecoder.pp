# Parses the Nginx error logs based on the Nginx hard coded internal format.
# It uses the sandboxdecoder
#
# === Parameters:
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
# $module_directory::             The directory where ‘require’ will attempt to load the external Lua modules from. Defaults to ${SHARE_DIR}/lua_modules.
#
# $tz::                           The conversion actually happens on the Go side since there isn’t good TZ support here.
#
# $type::                         Sets the message ‘Type’ header to the specified value
#

define heka::decoder::nginxerrorlogdecoder (
  # Common Sandbox Parameters
  $preserve_data          = undef,
  $memory_limit           = undef,
  $instruction_limit      = undef,
  $output_limit           = undef,
  $module_directory       = undef,
  # Nginx error logs Parameters
  $tz                     = 'UTC',
  $type                   = $name,
) {
  validate_string($tz)
  validate_string($type)

  heka::decoder::sandboxdecoder { $name:
    filename => 'lua_decoders/nginx_error.lua',
    config   => {
      tz   => $tz,
      type => $type,
    }
  }
}
