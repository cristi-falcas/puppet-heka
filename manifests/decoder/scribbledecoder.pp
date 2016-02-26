# The ScribbleDecoder is a trivial decoder that makes it possible to set one or more static field values on every decoded message.
# It is often used in conjunction with another decoder (i.e. in a MultiDecoder w/ cascade_strategy set to "all") to, for example,
# set the message type of every message to a specific custom value after the messages have been decoded from Protocol Buffers format.
# Note that this only supports setting the exact same value on every message, if any dynamic computation is required to determine what
# the value should be, or whether it should be applied to a specific message, a Sandbox Decoder using the provided write_message
# API call should be used instead.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
# $message_fields::               Subsection defining message fields to populate. Optional representation metadata can be added at the
#                                 end of the field name using a pipe delimiter i.e. host|ipv4 = "192.168.55.55" will create Fields[Host]
#                                 containing an IPv4 address. Adding a representation string to a standard message header name will cause
#                                 it to be added as a user defined field, i.e. Payload|json will create Fields[Payload] with a json representation
#                                 (see Field Variables). Does not support Timestamp or Uuid.
#
define heka::decoder::scribbledecoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  # lint:ignore:parameter_order
  $message_fields,
  # lint:endignore
) {
  $full_name = "scribbledecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/decoder/scribbledecoder.toml.erb"),
  }
}
