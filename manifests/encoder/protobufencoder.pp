# The ProtobufEncoder is used to serialize Heka message objects back into Heka's standard protocol buffers format.
# This is the format that Heka uses to communicate with other Heka instances, so one will always be included in your
# Heka configuration using the default "ProtobufEncoder" name whether specified or not.
# The hekad protocol buffers message schema is defined in the message.proto file in the message package.
#
# === Parameters: none
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
define heka::encoder::protobufencoder (
  $ensure = 'present',
) {
  validate_re($ensure, '^(present|absent)$')

  $decoder_type = 'ProtobufEncoder'

  heka::snippet { $name:
    ensure  => $ensure,
    content => template("${module_name}/noparamsxxcoder.toml.erb"),
  }
}
