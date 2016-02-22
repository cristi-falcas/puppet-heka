# Parses a payload containing JSON.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### JSON Parameters
#
# $type::                         Sets the message 'Type' header to the specified value, will be overridden if Type config option is
#                                 specified.
#                                 Default "json"
#                                 Type: string
#
# $payload_keep::                 Whether to preserve the original log line in the message payload.
#                                 Default false
#                                 Type: bool
#
# $map_fields::                   Enables mapping of json fields to heka message fields.
#                                 Default false
#                                 Type: bool
#
# $payload::                      String specifying json field to map to message Payload, expects field value to be a string.
#                                 Overrides the keep_payload config option.
#                                 Default nil
#                                 Type: string
#
# $uuid::                         String specifying json field to map to message Uuid, expects field value to be a string.
#                                 Default nil
#                                 Type: string
#
# $message_type::                 String specifying json field to map to to message Type, expects field value to be a string.
#                                 Overrides the type config option
#                                 Default nil
#                                 Type: string
#
# $logger::                       String specifying json field to map to message Logger, expects field value to be a string.
#                                 Default nil
#                                 Type: string
#
# $hostname::                     String specifying json field to map to message Hostname, expects field value to be a string.
#                                 Default nil
#                                 Type: string
#
# $severity::                     String specifying json field to map to message Severity, expects field value to be numeric.
#                                 Default nil
#                                 Type: string
#
# $envversion::                   String specifying json field to map to message EnvVersion, expects field value to be numeric.
#                                 Default nil
#                                 Type: string
#
# $pid::                          String specifying json field to map to message Pid, expects field value to be numeric
#                                 Default nil
#                                 Type: string
#
# $timestamp::                    String specifying json field to map to message Timestamp, if field value not in ns-since-epoch
#                                 format, provide the timestamp_format config option.
#                                 Default nil
#                                 Type: string
#
# $timestamp_format::             String specifying the format used to parse extracted JSON values for the Timestamp fields, in standard
#                                 strftime format.
#                                 If left blank, timestamp values will be assumed to be in nanoseconds-since-epoch.
#                                 Default nil
#                                 Type: string
#
define heka::decoder::jsondecoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  # JSON Parameters
  $type              = 'json',
  $payload_keep      = false,
  $map_fields        = false,
  $payload           = undef,
  $uuid              = undef,
  $message_type      = undef,
  $logger            = undef,
  $hostname          = undef,
  $severity          = undef,
  $envversion        = undef,
  $pid               = undef,
  $timestamp         = undef,
  $timestamp_format  = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # JSON Parameters
  validate_string($type)
  validate_bool($payload_keep, $map_fields)
  if $payload { validate_string($payload) }
  if $uuid { validate_string($uuid) }
  if $message_type { validate_string($message_type) }
  if $logger { validate_string($logger) }
  if $hostname { validate_string($hostname) }
  if $severity { validate_string($severity) }
  if $envversion { validate_string($envversion) }
  if $pid { validate_string($pid) }
  if $timestamp { validate_string($timestamp) }
  if $timestamp_format { validate_string($timestamp_format) }

  $sandbox_type = 'SandboxDecoder'
  $script_type = 'lua'
  $filename = 'lua_decoders/json.lua'
  $config = {
    'type'             => $type,
    'payload_keep'     => $payload_keep,
    'map_fields'       => $map_fields,
    'Payload'          => $payload,
    'Uuid'             => $uuid,
    'Type'             => $message_type,
    'Logger'           => $logger,
    'Hostname'         => $hostname,
    'Severity'         => $severity,
    'EnvVersion'       => $envversion,
    'Pid'              => $pid,
    'Timestamp'        => $timestamp,
    'timestamp_format' => $timestamp_format,
  }

  $full_name = "jsondecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}
