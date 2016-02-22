# Produces more human readable alert messages.
# It uses the sandboxencoder
#
# === Parameters
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxencoder for common parameters
#
define heka::encoder::alertencoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }

  $sandbox_type = 'SandboxEncoder'
  $script_type = 'lua'
  $filename = 'lua_encoders/alert.lua'

  $full_name = "alertencoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
