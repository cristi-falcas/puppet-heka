# This encoder serializes a Heka message into a clean JSON format, preceded by a separate JSON structure containing information
# required for ElasticSearch BulkAPI indexing. The JSON serialization is done by hand, without the use of Go's stdlib JSON
# marshalling. This is so serialization can succeed even if the message contains invalid UTF-8 characters, which will be encoded as
# U+FFFD.
#
# === Parameters:
#
# $index::                               Name of the ES index into which the messages will be inserted.
#                                        Supports interpolation of message field values (from 'Type', 'Hostname',
#                                        'Pid', 'UUID', 'Logger', 'EnvVersion', 'Severity', a field name, or a timestamp format)
#                                        with the use of '%{}' chars, so '%{Hostname}-%{Logger}-data' would add
#                                        the records to an ES index called 'some.example.com-processname-data'.
#                                        Allows to use strftime format codes. Defaults to 'heka-%{%Y.%m.%d}'.
#
# $type_name::                           Name of ES record type to create. Supports interpolation of message field values
#                                        (from 'Type', 'Hostname', 'Pid', 'UUID', 'Logger', 'EnvVersion', 'Severity', field name, or
#                                        a timestamp format) with the use of '%{}' chars, so '%{Hostname}-stat' would create an ES
#                                        record with a type of 'some.example.com-stat'.
#                                        Defaults to 'message'.
#
# $fields::                              The 'fields' parameter specifies that only specific message data should be indexed into
#                                        ElasticSearch.
#                                        Available fields to choose are "Uuid", "Timestamp", "Type", "Logger", "Severity",
#                                        "Payload", "EnvVersion", "Pid", "Hostname", and "DynamicFields" (where "DynamicFields" causes
#                                        the inclusion of dynamically specified message fields, see dynamic_fields). Defaults to
#                                        including all of the supported message fields.
#
# $timestamp::                           Format to use for timestamps in generated ES documents. Allows to use strftime format
#                                        codes.
#                                        Defaults to "%Y-%m-%dT%H:%M:%S".
#
# $es_index_from_timestamp::             When generating the index name use the timestamp from the message instead of the current
#                                        time. Defaults to false.
#
# $id::                                  Allows you to optionally specify the document id for ES to use. Useful for overwriting
#                                        existing ES documents.
#                                        If the value specified is placed within %{}, it will be interpolated to its Field value.
#                                        Default is allow ES to auto-generate the id.
#
# $raw_bytes_fields::                    This specifies a set of fields which will be passed through to the encoded JSON output
#                                        without any processing or escaping. This is useful for fields which contain embedded JSON
#                                        objects to prevent the embedded JSON from being escaped as normal strings.
#                                        Only supports dynamically specified message fields.
#
# $field_mappings::                      Maps Heka message fields to custom ES keys. Can be used to implement a custom format
#                                        in ES or implement Logstash V1. The available fields are "Timestamp", "Uuid", "Type",
#                                        "Logger", "Severity", "Payload", "EnvVersion", "Pid" and "Hostname".
#
# $dynamic_fields::                      This specifies which of the message's dynamic fields should be included in the JSON output.
#                                        Defaults to including all of the messages dynamic fields.
#                                        If dynamic_fields is non-empty, then the fields list must contain "DynamicFields" or an
#                                        error will be raised.
#

define heka::encoder::esjsonencoder (
  $index                   = 'heka-%{2006.01.02}',
  $type_name               = 'message',
  $fields                  = undef,
  $timestamp               = '2006-01-02T15:04:05.000Z',
  $es_index_from_timestamp = false,
  $id                      = undef,
  $raw_bytes_fields        = undef,
  $field_mappings          = undef,
  $dynamic_fields          = undef,
) {
  validate_string($index)
  validate_string($type_name)
  validate_string($timestamp)
  validate_bool($es_index_from_timestamp)
  if $id { validate_string($id) }

  $plugin_name = "elasticsearch_${name}"
  heka::snippet { $plugin_name:
    ensure  => 'file',
    content => template("${module_name}/encoder/esjsonencoder.toml.erb"),
  }
}
