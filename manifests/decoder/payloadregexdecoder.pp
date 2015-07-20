define heka::decoder::payloadregexdecoder (
  $match_regex,
  $severity_map       = undef,
  $message_fields     = undef,
  $timestamp_layout   = undef,
  $timestamp_location = undef,
  $log_errors         = undef,
) {
  heka::snippet { $name: content => template("${module_name}/decoder/payloadregexdecoder.toml.erb"), }
}
