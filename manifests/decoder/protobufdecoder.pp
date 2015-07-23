# The ProtobufDecoder is used for Heka message objects that have been serialized into protocol buffers format.
# This is the format that Heka uses to communicate with other Heka instances, so one will always be included
# in your Heka configuration under the name “ProtobufDecoder”, whether specified or not.
# The ProtobufDecoder has no configuration options.
#
# === Parameters: none
#
define heka::decoder::protobufdecoder {
  heka::snippet { $name: content => template("${module_name}/decoder/protobufdecoder.toml.erb"), }
}
