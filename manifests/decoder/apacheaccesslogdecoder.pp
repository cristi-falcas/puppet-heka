# Parses the Apache access logs based on the Apache 'LogFormat' configuration directive.
# The Apache format specifiers are mapped onto the Nginx variable names where applicable e.g. %a -> remote_addr.
# This allows generic web filters and outputs to work with any HTTP server input.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### Apache access log Parameters
#
# $log_format::                   The 'LogFormat' configuration directive from the apache2.conf. %t variables are converted to
#                                 the number of nanosecond since the Unix epoch and used to set the Timestamp on the message.
#                                 http://httpd.apache.org/docs/2.4/mod/mod_log_config.html
#                                 Example: '%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"'
#                                 Type: string
#
# $type::                         Sets the message 'Type' header to the specified value
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
define heka::decoder::apacheaccesslogdecoder (
  $ensure                 = 'present',
  # Common Sandbox Parameters
  $preserve_data          = undef,
  $memory_limit           = undef,
  $instruction_limit      = undef,
  $output_limit           = undef,
  $module_directory       = undef,
  # Apache access logs Parameters
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
  # Apache access logs Parameters
  validate_string($log_format)
  if $type { validate_string($type) }
  validate_bool($user_agent_transform, $user_agent_keep, $user_agent_conditional, $payload_keep)

  $sandbox_type = 'SandboxDecoder'
  $script_type = 'lua'
  $filename = 'lua_decoders/apache_access.lua'
  $config = {
    'log_format'             => $log_format,
    'type'                   => $type,
    'user_agent_transform'   => $user_agent_transform,
    'user_agent_keep'        => $user_agent_keep,
    'user_agent_conditional' => $user_agent_conditional,
    'payload_keep'           => $payload_keep,
  }

  $full_name = "apacheaccesslogdecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
