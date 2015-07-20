# == Class: heka::encoder::esjsonencoder
define heka::encoder::esjsonencoder (
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

  $plugin_name = "elasticsearch_${name}"
  heka::snippet { $plugin_name:
    content => template("${module_name}/encoder/esjsonencoder.toml.erb"),
    ensure  => 'file',
  }
}
