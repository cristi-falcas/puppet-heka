# Parses the Nginx access logs based on the Nginx ‘log_format’ configuration directive.
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
# $log_format::                   The ‘log_format’ configuration directive from the nginx.conf. $time_local or $time_iso8601
#                                 variable is converted to the number of nanosecond since the Unix epoch and used to set the
#                                 Timestamp on the message.
#                                 http://nginx.org/en/docs/http/ngx_http_log_module.html
#                                 Example: '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent
#                                 "$http_referer" "$http_user_agent"'
#
# $type::                         Sets the message ‘Type’ header to the specified value
#
# $user_agent_transform::         Transform the http_user_agent into user_agent_browser, user_agent_version, user_agent_os.
#
# $user_agent_keep::              Always preserve the http_user_agent value if transform is enabled.
#
# $user_agent_conditional::       Only preserve the http_user_agent value if transform is enabled and fails.
#
# $payload_keep::                 Always preserve the original log line in the message payload.
#

define heka::decoder::nginxaccesslogdecoder (
  # Common Sandbox Parameters
  $preserve_data          = undef,
  $memory_limit           = undef,
  $instruction_limit      = undef,
  $output_limit           = undef,
  $module_directory       = undef,
  # Nginx access logs Parameters
  $log_format,
  $type                   = undef,
  $user_agent_transform   = false,
  $user_agent_keep        = false,
  $user_agent_conditional = false,
  $payload_keep           = false,
) {
  if $type { validate_string($type) }
  validate_bool($user_agent_transform)
  validate_bool($user_agent_keep)
  validate_bool($user_agent_conditional)
  validate_bool($payload_keep)

  heka::decoder::sandboxdecoder { $name:
    filename => 'lua_decoders/nginx_access.lua',
    config   => {
      type                   => $type,
      user_agent_transform   => $user_agent_transform,
      user_agent_keep        => $user_agent_keep,
      user_agent_conditional => $user_agent_conditional,
      payload_keep           => $payload_keep,
    }
  }
}
