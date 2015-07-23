# Prepends ElasticSearch BulkAPI index JSON to a message payload.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $index::                               (string, optional, default “heka-%{%Y.%m.%d}”)
#                                        String to use as the _index key’s value in the generated JSON.
#                                        Supports field interpolation as described below.
#
# $type_name::                           (string, optional, default “message”)
#                                        String to use as the _type key’s value in the generated JSON.
#
# $es_index_from_timestamp::             (boolean, optional)
#                                        If true, then any time interpolation (often used to generate the ElasticSeach index)
#                                        will use the timestamp from the processed message rather than the system time.
#
# $id::                                  (string, optional)
#                                        String to use as the _id key’s value in the generated JSON.
#                                        Supports field interpolation as described below
#
define heka::encoder::es_payload (
  $index                   = 'heka-%{2006.01.02}',
  $type_name               = 'message',
  $es_index_from_timestamp = false,
  $id                      = undef,
) {
  validate_string($index)
  validate_string($type_name)
  validate_bool($es_index_from_timestamp)
  if $id { validate_string($id) }

  heka::encoder::sandboxencoder { $name:
    filename => "lua_encoders/es_payload.lua",
    config   => {
      index                   => $index,
      type_name               => $type_name,
      es_index_from_timestamp => $es_index_from_timestamp,
      id                      => $id,
    }
  }
}
