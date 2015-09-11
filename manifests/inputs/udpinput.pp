# Listens on a specific UDP address and port for messages. If the message is signed it is verified against
# the signer name and specified key version. If the signature is not valid the message is discarded otherwise
# the signer name is added to the pipeline pack and can be use to accept messages using the message_signer configuration option.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $splitter::                    Splitter to be used by the input. This should refer to the name of a
#                                registered splitter plugin configuration. It specifies how the input
#                                should split the incoming data stream into individual records prior
#                                to decoding and/or injection to the router. Typically defaults to “NullSplitter”,
#                                although certain inputs override this with a different default value.
#
# $decoder::                     Decoder to be used by the input. This should refer to the name of a registered
#                                decoder plugin configuration. If supplied, messages will be decoded before being
#                                passed on to the router when the InputRunner’s Deliver method is called.
#
# $synchronous_decode::          If synchronous_decode is false, then any specified decoder plugin will be
#                                run by a DecoderRunner in its own goroutine and messages will be passed in
#                                to the decoder over a channel, freeing the input to start processing the
#                                next chunk of incoming or available data. If true, then any decoding will
#                                happen synchronously and message delivery will not return control to the
#                                input until after decoding has completed. Defaults to false.
#
# $send_decode_failures::        If false, then if an attempt to decode a message fails then Heka will log
#                                an error message and then drop the message. If true, then in addition to
#                                logging an error message, decode failure will cause the original, undecoded
#                                message to be tagged with a decode_failure field (set to true) and delivered
#                                to the router for possible further processing.
#
# $can_exit::                    If false, the input plugin exiting will trigger a Heka shutdown. If set to true,
#                                Heka will continue processing other plugins. Defaults to false on most inputs.
#
# $host, $port::                 An IP address:port or Unix datagram socket file path on which this plugin will listen.
#
# $signer                        Section name consists of a signer name, underscore, and numeric version of the key
#
# $net                           Network value must be one of: “udp”, “udp4”, “udp6”, or “unixgram”.
#
# $set_hostname                  Set Hostname field from remote address.
#

define heka::inputs::udpinput (
  $ensure                       = 'present',
  # Common Input Parameters
  $decoder                      = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit                     = undef,
  $splitter                     = 'HekaFramingSplitter',
  # UDP Input
  $address                      = ':514',
  $signer                       = undef,
  $net                          = 'udp',
  $set_hostname                 = false,
) {
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  validate_string($splitter)
  # UDP Input
  validate_string($address)
  if $signer { validate_string($signer) }
  validate_string($net)
  validate_bool($set_hostname)

  $plugin_name = "udpinput_${name}"
  heka::snippet { $plugin_name:
    content => template("${module_name}/plugin/udpinput.toml.erb"),
    ensure  => $ensure,
  }
}
