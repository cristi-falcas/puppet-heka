# Parses the Nginx error logs based on the Nginx hard coded internal format.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### Nginx error log Parameters
#
# $tz::                           The conversion actually happens on the Go side since there isn't good TZ support here.
#                                 Type: string
#
# $type::                         Sets the message 'Type' header to the specified value
#                                 Type: string
#
define heka::decoder::nginxerrorlogdecoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  # Nginx error logs Parameters
  $tz                = 'UTC',
  $type              = $name,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # Nginx error logs Parameters
  validate_string($tz)
  validate_string($type)

  $sandbox_type = 'SandboxDecoder'
  $script_type = 'lua'
  $filename = 'lua_decoders/nginx_error.lua'
  $config = {
    'tz'   => $tz,
    'type' => $type,
  }

  $full_name = "nginxerrorlogdecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
