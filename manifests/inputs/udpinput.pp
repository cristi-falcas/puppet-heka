# Listens on a specific UDP address and port for messages. If the message is signed it is verified against
# the signer name and specified key version. If the signature is not valid the message is discarded otherwise
# the signer name is added to the pipeline pack and can be use to accept messages using the message_signer configuration option.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Input Parameters::    Check heka::inputs::tcpinput for the description
#
# $address::                     An IP address:port or Unix datagram socket file path on which this plugin will listen.
#
# $signer                        Section name consists of a signer name, underscore, and numeric version of the key
#
# $net                           Network value must be one of: "udp", "udp4", "udp6", or "unixgram".
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
  $log_decode_failures          = true,
  # UDP Input
  $address                      = ':514',
  $signer                       = undef,
  $net                          = 'udp',
  $set_hostname                 = false,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $splitter { validate_string($splitter) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # UDP Input
  validate_string($address)
  if $signer { validate_string($signer) }
  validate_string($net)
  validate_bool($set_hostname)

  $full_name = "udpinput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/udpinput.toml.erb"),
  }
}
