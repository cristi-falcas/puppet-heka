# Converts full Heka message contents to JSON for InfluxDB HTTP API. Includes all standard message fields and iterates
# through all of the dynamically specified fields, skipping any bytes fields or any fields explicitly omitted using the
# skip_fields config option.
#
# === Parameters
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### Schema InfluxDB Parameters
# $series::                       String to use as the series key's value in the generated JSON. Supports interpolation
#                                 of field values from the processed message, using %{fieldname}. Any fieldname values of
#                                 "Type", "Payload", "Hostname", "Pid", "Logger", "Severity", or "EnvVersion" will be extracted
#                                 from the the base message schema, any other values will be assumed to refer to a dynamic message
#                                 field. Only the first value of the first instance of a dynamic message field can be used for series
#                                 name interpolation. If the dynamic field doesn't exist, the uninterpolated value will be left in
#                                 the series name. Note that it is not possible to interpolate either the "Timestamp" or the "Uuid"
#                                 message fields into the series name, those values will be interpreted as referring to dynamic message
#                                 fields.
#                                 Default: "series"
#                                 Type: string
#
# $skip_fields::                  Space delimited set of fields that should not be included in the InfluxDB records being generated.
#                                 Any fieldname values of "Type", "Payload", "Hostname", "Pid", "Logger", "Severity", or
#                                 "EnvVersion" will be assumed to refer to the corresponding field from the base message schema.
#                                 Any other values will be assumed to refer to a dynamic message field.
#                                 Default: ""
#                                 Type: string
#
# $multi_series::                 Instead of submitting all fields to InfluxDB as attributes of a single series, submit a series for
#                                 each field that sets a "value" attribute to the value of the field. This also sets the name attribute
#                                 to the series value with the field name appended to it by a ".". This is the recommended by InfluxDB
#                                 for v0.9 onwards as it is found to provide better performance when querying and aggregating across
#                                 multiple series.
#                                 Default: false
#                                 Type: bool
#
# $exclude_base_fields::          Don't send the base fields to InfluxDB. This saves storage space by not including base fields
#                                 that are mostly redundant and unused data. If skip_fields includes base fields, this overrides
#                                 it and will only be relevant for skipping dynamic fields.
#                                 Default: false
#                                 Type: bool
#
define heka::encoder::schema_influxencoder (
  $ensure              = 'present',
  # Common Sandbox Parameters
  $preserve_data       = undef,
  $memory_limit        = undef,
  $instruction_limit   = undef,
  $output_limit        = undef,
  $module_directory    = undef,
  # Schema InfluxDB Parameters
  $series              = undef,
  $skip_fields         = undef,
  $multi_series        = undef,
  $exclude_base_fields = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # Schema InfluxDB Parameters
  if $series { validate_string($series) }
  if $skip_fields { validate_string($skip_fields) }
  if $multi_series { validate_bool($multi_series) }
  if $exclude_base_fields { validate_bool($exclude_base_fields) }

  $sandbox_type = 'SandboxEncoder'
  $script_type = 'lua'
  $filename = 'lua_encoders/schema_influx.lua'
  $config = {
    'series'              => $series,
    'skip_fields'         => $skip_fields,
    'multi_series'        => $multi_series,
    'exclude_base_fields' => $exclude_base_fields,
  }

  $full_name = "schema_influx_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
