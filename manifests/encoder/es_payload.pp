# Prepends ElasticSearch BulkAPI index JSON to a message payload.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $preserve_data::                True if the sandbox global data should be preserved/restored on plugin shutdown/startup.
#                                 When true this works in conjunction with a global Lua _PRESERVATION_VERSION variable which
#                                 is examined during restoration; if the previous version does not match the current version
#                                 the restoration will be aborted and the sandbox will start cleanly. _PRESERVATION_VERSION should
#                                 be incremented any time an incompatible change is made to the global data schema. If no version
#                                 is set the check will always succeed and a version of zero is assumed.
#
# $memory_limit::                 The number of bytes the sandbox is allowed to consume before being terminated (default 8MiB).
#
# $instruction_limit::            The number of instructions the sandbox is allowed to execute during the
#                                 process_message/timer_event functions before being terminated (default 1M).
#
# $output_limit::                 The number of bytes the sandbox output buffer can hold before being terminated (default 63KiB).
#                                 Warning: messages exceeding 64KiB will generate an error and be discarded by the standard output
#                                 plugins (File, TCP, UDP) since they exceed the maximum message size.
#
# $module_directory::             The directory where ‘require’ will attempt to load the external Lua modules from. Defaults to ${SHARE_DIR}/lua_modules.
#
# $index::                        (string, optional, default “heka-%{%Y.%m.%d}”)
#                                 String to use as the _index key’s value in the generated JSON.
#                                 Supports field interpolation as described below.
#
# $type_name::                    (string, optional, default “message”)
#                                 String to use as the _type key’s value in the generated JSON.
#
# $es_index_from_timestamp::      (boolean, optional)
#                                 If true, then any time interpolation (often used to generate the ElasticSeach index)
#                                 will use the timestamp from the processed message rather than the system time.
#
# $id::                           (string, optional)
#                                 String to use as the _id key’s value in the generated JSON.
#                                 Supports field interpolation as described below
#

define heka::encoder::es_payload (
  # Common Sandbox Parameters
  $preserve_data           = undef,
  $memory_limit            = undef,
  $instruction_limit       = undef,
  $output_limit            = undef,
  $module_directory        = undef,
  # ElasticSearch Parameters
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
    filename => 'lua_encoders/es_payload.lua',
    config   => {
      index                   => $index,
      type_name               => $type_name,
      es_index_from_timestamp => $es_index_from_timestamp,
      id                      => $id,
    },
  }
}
