# Output plugin that delivers Heka message data to a specified UDP or Unix datagram socket location.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $message_matcher::             Boolean expression, when evaluated to true passes the message to the filter for processing.
#                                Defaults to matching nothing
#
# $message_signer::              The name of the message signer. If specified only messages with this signer are passed to the
#                                filter for processing.
#
# $ticker_interval::             Frequency (in seconds) that a timer event will be sent to the filter. Defaults to not sending timer
#                                events.
#
# $encoder::                     Encoder to be used by the output. This should refer to the name of an encoder plugin section that
#                                is specified elsewhere in the TOML configuration.
#                                Messages can be encoded using the specified encoder by calling the OutputRunner’s Encode() method.
#
# $use_framing::                 Specifies whether or not Heka’s Stream Framing should be applied to the binary data returned from
#                                the OutputRunner’s Encode() method.
#
# $can_exit::                    Whether or not this plugin can exit without causing Heka to shutdown. Defaults to false.
#
# $net::                         Network type to use for communication. Must be one of “udp”, “udp4”, “udp6”, or “unixgram”.
#                                “unixgram” option only available on systems that support Unix datagram sockets.
#                                Defaults to “udp”.
#
# $address::                     Address to which we will be sending the data. Must be IP:port for net types of “udp”, “udp4”, or
#                                “udp6”. Must be a path to a Unix datagram socket file for net type “unixgram”.
#
# $local_address::               Local address to use on the datagram packets being generated. Must be IP:port for net types of
#                                “udp”, “udp4”, or “udp6”.
#                                Must be a path to a Unix datagram socket file for net type “unixgram”.
#
# $max_message_size::            Maximum size of message that is allowed to be sent via UdpOutput. Messages which exceeds this limit
# will be dropped.
#                                Defaults to 65507 (the limit for UDP packets in IPv4).
#

define heka::outputs::udpoutput (
  $ensure                       = 'present',
  # Common Output Parameters
  $message_matcher              = undef,
  $message_signer               = undef,
  $ticker_interval              = 300,
  $encoder                      = 'ProtobufEncoder',
  $use_framing                  = undef,
  $can_exit                     = undef,
  # TCP Output
  $net                          = 'udp',
  $address,
  $local_address                = undef,
  $max_message_size             = 65507,
) {
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  validate_integer($ticker_interval)
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  # UDP Output Parameters
  validate_string($net)
  validate_string($address)
  validate_string($local_address)
  validate_integer($max_message_size)

  $plugin_name = "udpoutput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/udpoutput.toml.erb"),
  }
}
