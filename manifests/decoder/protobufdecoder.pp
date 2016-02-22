# The ProtobufDecoder is used for Heka message objects that have been serialized into protocol buffers format.
# This is the format that Heka uses to communicate with other Heka instances, so one will always be included
# in your Heka configuration under the name "ProtobufDecoder", whether specified or not.
# The ProtobufDecoder has no configuration options.
#
# === Parameters
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
define heka::decoder::protobufdecoder (
  $ensure = 'present',
) {
  validate_re($ensure, '^(present|absent)$')

  $decoder_type = 'ProtobufDecoder'

  heka::snippet { $name:
    ensure  => $ensure,
    content => template("${module_name}/noparamsxxcoder.toml.erb"),
  }
}
