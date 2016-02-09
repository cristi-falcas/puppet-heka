# Output plugin that delivers Heka message data to a specified UDP or Unix datagram socket location.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
### Common Output Parameters::   Check heka::outputs::tcpoutput for the description
#
### TCP Output Parameters ###
# $net::                         Network type to use for communication. Must be one of "udp", "udp4", "udp6", or "unixgram".
#                                "unixgram" option only available on systems that support Unix datagram sockets.
#                                Defaults to "udp".
#
# $address::                     Address to which we will be sending the data. Must be IP:port for net types of "udp", "udp4", or
#                                "udp6". Must be a path to a Unix datagram socket file for net type "unixgram".
#
# $local_address::               Local address to use on the datagram packets being generated. Must be IP:port for net types of
#                                "udp", "udp4", or "udp6".
#                                Must be a path to a Unix datagram socket file for net type "unixgram".
#
# $max_message_size::            Maximum size of message that is allowed to be sent via UdpOutput. Messages which exceeds this limit
#                                will be dropped.
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
  $use_buffering                = undef,
  # Buffering
  $max_file_size                = undef,
  $max_buffer_size              = undef,
  $full_action                  = undef,
  $cursor_update_count          = undef,
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
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
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
