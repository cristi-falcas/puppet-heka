# == Class: heka::encoder::es_payload
define heka::encoder::es_payload (
  $index       = 'heka-%{2006.01.02}',
  $type_name   = 'message',
  $fields      = undef,
  $timestamp   = '2006-01-02T15:04:05.000Z',
  $es_index_from_timestamp = false,
  $id          = undef,
  $raw_bytes_fields        = undef,
  $field_mappings          = undef,
) {
  validate_string($index)
  validate_string($type_name)
  validate_string($timestamp)
  validate_bool($es_index_from_timestamp)
  if $id { validate_string($id) }

  heka::encoder::sandboxencoder { $name:
    filename => "lua_encoders/es_payload.lua",
    config   => {
      index     => $index,
      type_name => $type_name,
      timestamp => $timestamp,
      es_index_from_timestamp => $es_index_from_timestamp,
      id        => $id,
      raw_bytes_fields        => $raw_bytes_fields,
      field_mappings          => $field_mappings,
    }
  }
}
