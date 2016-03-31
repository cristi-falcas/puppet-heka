# Converts full Heka message contents to line protocol for Carbon Plaintext API Iterates through all of the dynamic
# fields to add as points (series), skipping any fields explicitly omitted using the skip_fields config option.
# All dynamic fields in the Heka message are converted to separate points separated by newlines that are submitted to Carbon.
# It uses the sandboxencoder
#
# === Parameters
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### Schema Carbon Line Parameters
# $name_prefix::                  String to use as the name key's prefix value in the generated line.
#                                 Supports message field interpolation.
#                                 %{fieldname}. Any fieldname values of "Type", "Payload", "Hostname", "Pid", "Logger",
#                                 "Severity", or "EnvVersion" will be extracted from the the base message schema,
#                                 any other values will be assumed to refer to a dynamic message field.
#                                 Only the first value of the first instance of a dynamic message field can be used for name
#                                 name interpolation. If the dynamic field doesn't exist, the uninterpolated value will be left
#                                 in the name. Note that it is not possible to interpolate either the "Timestamp" or the "Uuid"
#                                 message fields into the name, those values will be interpreted as referring to dynamic
#                                 message fields.
#                                 Default: nil
#                                 Type: string
#
# $name_prefix_delimiter::        String to use as the delimiter between the name_prefix and the field name. This defaults to a "."
#                                 to use Graphite naming convention.
#                                 Default: ""
#                                 Type: string
#
# $skip_fields::                  Space delimited set of fields that should not be included in the Carbon records being generated.
#                                 Any fieldname values of "Type", "Payload", "Hostname", "Pid", "Logger", "Severity", or
#                                 "EnvVersion" will be assumed to refer to the corresponding field from the base message schema.
#                                 Any other values will be assumed to refer to a dynamic message field. The magic value "all_base"
#                                 can be used to exclude base fields from being mapped to the event altogether.
#                                 Default: nil
#                                 Type: string
#
# $source_value_field::           If the desired behavior of this encoder is to extract one field from the Heka message and feed it
#                                 as a single line to Carbon, then use this option to define which field to find the value from.
#                                 Make sure to set the name_prefix value to use fields from the message with field interpolation so
#                                 the full metric path in Graphite is populated. When this option is present, no other fields
#                                 besides this one will be sent to Carbon whatsoever.
#                                 Default: nil
#                                 Type: string
#
define heka::encoder::schema_carbon_lineencoder (
  $ensure                = 'present',
  # Common Sandbox Parameters
  $preserve_data         = undef,
  $memory_limit          = undef,
  $instruction_limit     = undef,
  $output_limit          = undef,
  $module_directory      = undef,
  # Schema Carbon Line Parameters
  $name_prefix           = undef,
  $name_prefix_delimiter = undef,
  $skip_fields           = undef,
  $source_value_field    = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # Schema Carbon Line Parameters
  if $name_prefix { validate_string($name_prefix) }
  if $name_prefix_delimiter { validate_string($name_prefix_delimiter) }
  if $skip_fields { validate_string($skip_fields) }
  if $source_value_field { validate_string($source_value_field) }

  $sandbox_type = 'SandboxEncoder'
  $script_type = 'lua'
  $filename = 'lua_encoders/schema_carbon_line.lua'
  $config = {
    'name_prefix'           => $name_prefix,
    'name_prefix_delimiter' => $name_prefix_delimiter,
    'skip_fields'           => $skip_fields,
    'source_value_field'    => $source_value_field,
  }

  $full_name = "schema_carbon_line_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
