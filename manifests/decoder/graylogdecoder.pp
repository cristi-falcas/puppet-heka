# Parses a payload containing JSON in the Graylog2 Extended Format specficiation.
# http://graylog2.org/resources/gelf/specification
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### Graylog Extended Parameters
#
# $type::                         Sets the message 'Type' header to the specified value
#                                 Type: string
#
# $payload_keep::                 Always preserve the original log line in the message payload.
#                                 Type: bool
#
define heka::decoder::graylogdecoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  # Graylog Extended Parameters
  # lint:ignore:parameter_order
  $type,
  $payload_keep,
  # lint:endignore
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($type) }
  # Graylog Parameters
  validate_string($type)
  validate_bool($payload_keep)

  $sandbox_type = 'SandboxDecoder'
  $script_type = 'lua'
  $filename = 'lua_decoders/graylog_decoder.lua'
  $config = {
    'type'         => $type,
    'payload_keep' => $payload_keep,
  }

  $full_name = "graylogdecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
