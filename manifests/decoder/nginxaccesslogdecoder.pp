# Parses the Nginx access logs based on the Nginx 'log_format' configuration directive.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### Nginx access log Parameters
#
# $log_format::                   The 'log_format' configuration directive from the nginx.conf. $time_local or $time_iso8601
#                                 variable is converted to the number of nanosecond since the Unix epoch and used to set the
#                                 Timestamp on the message.
#                                 http://nginx.org/en/docs/http/ngx_http_log_module.html
#                                 Example: '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent
#                                 "$http_referer" "$http_user_agent"'
#                                 Type: string
#
# $type::                         Sets the message 'Type' header to the specified value
#                                 Default: nil
#                                 Type: string
#
# $user_agent_transform::         Transform the http_user_agent into user_agent_browser, user_agent_version, user_agent_os.
#                                 Type: bool
#
# $user_agent_keep::              Always preserve the http_user_agent value if transform is enabled.
#                                 Type: bool
#
# $user_agent_conditional::       Only preserve the http_user_agent value if transform is enabled and fails.
#                                 Type: bool
#
# $payload_keep::                 Always preserve the original log line in the message payload.
#                                 Type: bool
#
define heka::decoder::nginxaccesslogdecoder (
  $ensure                 = 'present',
  # Common Sandbox Parameters
  $preserve_data          = undef,
  $memory_limit           = undef,
  $instruction_limit      = undef,
  $output_limit           = undef,
  $module_directory       = undef,
  # Nginx access logs Parameters
  # lint:ignore:parameter_order
  $log_format,
  # lint:endignore
  $type                   = $name,
  $user_agent_transform   = false,
  $user_agent_keep        = false,
  $user_agent_conditional = false,
  $payload_keep           = false,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # Nginx access logs Parameters
  validate_string($log_format)
  if $type { validate_string($type) }
  validate_bool($user_agent_transform)
  validate_bool($user_agent_keep)
  validate_bool($user_agent_conditional)
  validate_bool($payload_keep)

  $sandbox_type = 'SandboxDecoder'
  $script_type = 'lua'
  $filename = 'lua_decoders/nginx_access.lua'
  $config = {
    'log_format'             => $log_format,
    'type'                   => $type,
    'user_agent_transform'   => $user_agent_transform,
    'user_agent_keep'        => $user_agent_keep,
    'user_agent_conditional' => $user_agent_conditional,
    'payload_keep'           => $payload_keep,
  }

  $full_name = "nginxaccesslogdecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
