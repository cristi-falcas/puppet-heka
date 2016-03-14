# Prepends ElasticSearch BulkAPI index JSON to a message payload.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### ElasticSearch Payload Parameters
# $index::                        String to use as the _index key's value in the generated JSON.
#                                 Supports field interpolation as described below.
#                                 Default "heka-%{%Y.%m.%d}"
#                                 Type: string
#
# $type_name::                    String to use as the _type key's value in the generated JSON.
#                                 Type: string
#
# $es_index_from_timestamp::      If true, then any time interpolation (often used to generate the ElasticSeach index)
#                                 will use the timestamp from the processed message rather than the system time.
#                                 Type: string
#
# $id::                           String to use as the _id key's value in the generated JSON.
#                                 Supports field interpolation as described below
#                                 Type: bool
#
define heka::encoder::es_payload (
  $ensure                  = 'present',
  # Common Sandbox Parameters
  $preserve_data           = undef,
  $memory_limit            = undef,
  $instruction_limit       = undef,
  $output_limit            = undef,
  $module_directory        = undef,
  # ElasticSearch Parameters
  $index                   = undef,
  $type_name               = 'message',
  $es_index_from_timestamp = false,
  $id                      = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # ElasticSearch Parameters
  validate_string($index)
  validate_string($type_name)
  validate_bool($es_index_from_timestamp)
  if $id { validate_string($id) }

  $sandbox_type = 'SandboxEncoder'
  $script_type = 'lua'
  $filename = 'lua_encoders/es_payload.lua'
  $config = {
    'index'                   => $index,
    'type_name'               => $type_name,
    'es_index_from_timestamp' => $es_index_from_timestamp,
    'id'                      => $id,
  }

  $full_name = "es_payload_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
