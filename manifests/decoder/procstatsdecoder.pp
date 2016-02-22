# Parses a payload containing the contents of file /proc/stat.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### ProcStats Parameters
#
# $payload_keep::                 Whether to preserve the original log line in the message payload.
#                                 Default false
#                                 Type: bool
#
define heka::decoder::procstatsdecoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  # ProcStats Parameters
  $payload_keep      = false,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # ProcStats Parameters
  validate_bool($payload_keep)

  $sandbox_type = 'SandboxDecoder'
  $script_type = 'lua'
  $filename = 'lua_decoders/linux_procstat.lua'
  $config = {
    'payload_keep' => $payload_keep,
  }

  $full_name = "procstatsdecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
