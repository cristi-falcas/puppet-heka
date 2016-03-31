# Converts full Heka message contents to line protocol for InfluxDB HTTP write API (new in InfluxDB v0.9.0).
# Optionally includes all standard message fields as tags or fields and iterates through all of the dynamic fields
# to add as points (series), skipping any fields explicitly omitted using the skip_fields config option.
# It can also map any Heka message fields as tags in the request sent to the InfluxDB write API, using the tag_fields
# config option. All dynamic fields in the Heka message are converted to separate points separated by newlines that
# are submitted to InfluxDB.
#
# === Parameters
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### Schema InfluxDB Line Parameters
# $decimal_precision::            String that is used in the string.format function to define the number of digits printed
#                                 after the decimal in number values. The string formatting of numbers is forced to print with
#                                 floating points because InfluxDB will reject values that change from integers to floats and
#                                 vice-versa. By forcing all numbers to floats, we ensure that InfluxDB will always accept our
#                                 numerical values, regardless of the initial format.
#                                 Default: "6"
#                                 Type: string
#
# $name_prefix::                  String to use as the name key's prefix value in the generated line. Supports message field
#                                 interpolation. %{fieldname}. Any fieldname values of "Type", "Payload", "Hostname", "Pid", "Logger",
#                                 "Severity", or "EnvVersion" will be extracted from the the base message schema, any other values
#                                 will be assumed to refer to a dynamic message field. Only the first value of the first instance
#                                 of a dynamic message field can be used for name name interpolation. If the dynamic field doesn't exist,
#                                 the uninterpolated value will be left in the name. Note that it is not possible to interpolate
#                                 either the "Timestamp" or the "Uuid" message fields into the name, those values will be interpreted
#                                 as referring to dynamic message fields.
#                                 Default: nil
#                                 Type: string
#
# $name_prefix_delimiter::        String to use as the delimiter between the name_prefix and the field name.
#                                 This defaults to a blank string but can be anything else instead (such as "." to use Graphite-like
#                                 naming).
#                                 Default: nil
#                                 Type: string
#
# $skip_fields::                  Space delimited set of fields that should not be included in the InfluxDB records being generated.
#                                 Any fieldname values of "Type", "Payload", "Hostname", "Pid", "Logger", "Severity", or
#                                 "EnvVersion" will be assumed to refer to the corresponding field from the base message schema.
#                                 Any other values will be assumed to refer to a dynamic message field. The magic value "all_base"
#                                 can be used to exclude base fields from being mapped to the event altogether (useful if you don't
#                                 want to use tags and embed them in the name_prefix instead).
#                                 Default: nil
#                                 Type: string
#
# $source_value_field::           If the desired behavior of this encoder is to extract one field from the Heka message and feed
#                                 it as a single line to InfluxDB, then use this option to define which field to find the value from.
#                                 Be careful to set the name_prefix field if this option is present or no measurement name will be
#                                 present when trying to send to InfluxDB. When this option is present, no other fields besides this one
#                                 will be sent to InfluxDB as a measurement whatsoever.
#                                 Default: nil
#                                 Type: string
#
# $tag_fields::                   Take fields defined and add them as tags of the measurement(s) sent to InfluxDB for the message.
#                                 The magic values "all" and "all_base" are used to map all fields (including taggable base fields)
#                                 to tags and only base fields to tags, respectively. If those magic values aren't used, then only
#                                 those fields defined will map to tags of the measurement sent to InfluxDB. The tag_fields values
#                                 are independent of the skip_fields values and have no affect on each other. You can skip fields from
#                                 being sent to InfluxDB as measurements, but still include them as tags.
#                                 Default: "string"
#                                 Type: string
#
# $timestamp_precision::          Specify the timestamp precision that you want the event sent with. The default is to use milliseconds
#                                 by dividing the Heka message timestamp by 1e6, but this math can be altered by specifying one of the
#                                 precision values supported by the InfluxDB write API (ms, s, m, h). Other precisions supported by
#                                 InfluxDB of n and u are not yet supported.
#                                 Default: "ms"
#                                 Type: string
#
# $value_field_key::              This defines the name of the InfluxDB measurement. We default this to "value" to match the examples
#                                 in the InfluxDB documentation, but you can replace that with anything else that you prefer.
#                                 Default: "value"
#                                 Type: string
#
define heka::encoder::schema_influx_lineencoder (
  $ensure                = 'present',
  # Common Sandbox Parameters
  $preserve_data         = undef,
  $memory_limit          = undef,
  $instruction_limit     = undef,
  $output_limit          = undef,
  $module_directory      = undef,
  # Schema InfluxDB Line Parameters
  $decimal_precision     = undef,
  $name_prefix           = undef,
  $name_prefix_delimiter = undef,
  $skip_fields           = undef,
  $source_value_field    = undef,
  $tag_fields            = undef,
  $timestamp_precision   = undef,
  $value_field_key       = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # Schema InfluxDB Line Parameters
  if $decimal_precision { validate_string($decimal_precision) }
  if $name_prefix { validate_string($name_prefix) }
  if $name_prefix_delimiter { validate_string($name_prefix_delimiter) }
  if $skip_fields { validate_string($skip_fields) }
  if $source_value_field { validate_string($source_value_field) }
  if $tag_fields { validate_string($tag_fields) }
  if $timestamp_precision { validate_string($timestamp_precision) }
  if $value_field_key { validate_string($value_field_key) }

  $sandbox_type = 'SandboxEncoder'
  $script_type = 'lua'
  $filename = 'lua_encoders/schema_influx_line.lua'
  $config = {
    'decimal_precision'     => $decimal_precision,
    'name_prefix'           => $name_prefix,
    'name_prefix_delimiter' => $name_prefix_delimiter,
    'skip_fields'           => $skip_fields,
    'source_value_field'    => $source_value_field,
    'tag_fields'            => $tag_fields,
    'timestamp_precision'   => $timestamp_precision,
    'value_field_key'       => $value_field_key,
  }

  $full_name = "schema_influx_line_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
