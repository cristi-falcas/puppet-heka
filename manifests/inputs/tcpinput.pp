# Listens on a specific TCP address and port for messages. If the message is signed it is verified against
# the signer name and specified key version. If the signature is not valid the message is discarded otherwise
# the signer name is added to the pipeline pack and can be use to accept messages using the message_signer configuration option.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Input Parameters ###
#
# $decoder::                      Decoder to be used by the input. This should refer to the name of a registered
#                                 decoder plugin configuration. If supplied, messages will be decoded before being
#                                 passed on to the router when the InputRunner's Deliver method is called.
#                                 Type: string
#
# $synchronous_decode::           If synchronous_decode is false, then any specified decoder plugin will be
#                                 run by a DecoderRunner in its own goroutine and messages will be passed in
#                                 to the decoder over a channel, freeing the input to start processing the
#                                 next chunk of incoming or available data. If true, then any decoding will
#                                 happen synchronously and message delivery will not return control to the
#                                 input until after decoding has completed. Defaults to false.
#                                 Type: bool
#
# $send_decode_failures::         If false, then if an attempt to decode a message fails then Heka will log
#                                 an error message and then drop the message. If true, then in addition to
#                                 logging an error message, decode failure will cause the original, undecoded
#                                 message to be tagged with a decode_failure field (set to true) and delivered
#                                 to the router for possible further processing.
#                                 Type: bool
#
# $can_exit::                     If false, the input plugin exiting will trigger a Heka shutdown. If set to true,
#                                 Heka will continue processing other plugins. Defaults to false on most inputs.
#                                 Type: bool
#
# $splitter::                     Splitter to be used by the input. This should refer to the name of a
#                                 registered splitter plugin configuration. It specifies how the input
#                                 should split the incoming data stream into individual records prior
#                                 to decoding and/or injection to the router. Typically defaults to "NullSplitter",
#                                 although certain inputs override this with a different default value.
#                                 Type: string
#
# $log_decode_failures::          If true, then if an attempt to decode a message fails then Heka will log an error message.
#                                 Defaults to true. See also send_decode_failures.
#                                 Type: bool
#
### TLS Output Parameters ###
#
# $use_tls::                      Specifies whether or not SSL/TLS encryption should be used for the TCP connections.
#                                 Defaults to false.
#                                 Type: bool
#
# $tls_server_name::              Name of the server being requested. Included in the client handshake to support virtual hosting server environments.
#                                 Type: bool
#
# $tls_cert_file::                Full filesystem path to the certificate file to be presented to the other side of the connection.
#                                 Type: bool
#
# $tls_key_file::                 Full filesystem path to the specified certificate's associated private key file.
#                                 Type: bool
#
# $tls_client_auth::              Specifies the server's policy for TLS client authentication.
#                                 Defaults to "NoClientCert".
#                                 Type: bool
#
# $tls_ciphers::                  List of cipher suites supported for TLS connections. Earlier suites in the list have priority over
#                                 those following. If omitted, the implementation's default ordering will be used.
#                                 Type: bool
#
# $tls_insecure_skip_verify::     If true, TLS client connections will accept any certificate presented by the server and any host
#                                 name in that certificate. This causes TLS to be susceptible to man-in-the-middle attacks and should
#                                 only be used for testing.
#                                 Defaults to false.
#                                 Type: bool
#
# $tls_prefer_server_ciphers::    If true, a server will always favor the server's specified cipher suite priority order over
#                                 that requested by the client.
#                                 Defaults to true.
#                                 Type: bool
#
# $tls_session_tickets_disabled:: If true, session resumption support as specified in RFC 5077 will be disabled.
#                                 Type: bool
#
# $tls_session_ticket_key::       Used by the TLS server to provide session resumption per RFC 5077.
#                                 If left empty, it will be filled with random data before the first server handshake.
#                                 Type: bool
#
# $tls_min_version::              Specifies the mininum acceptable SSL/TLS version.
#                                 Defaults to SSL30.
#                                 Type: bool
#
# $tls_max_version::              Specifies the maximum acceptable SSL/TLS version.
#                                 Defaults to TLS12.
#                                 Type: bool
#
# $tls_client_cafile::            File for server to authenticate client TLS handshake. Any client certs recieved by server must
#                                 be chained to a CA found in this PEM file.
#                                 Has no effect when NoClientCert is set.
#                                 Type: bool
#
# $tls_root_cafile::              File for client to authenticate server TLS handshake. Any server certs recieved by client must
#                                 be must be chained to a CA found in this PEM file.
#                                 Type: bool
#
### TCP Input Parameters
#
# $address::                      An IP address:port on which this plugin will listen.
#                                 Type: string
#
# $net::                          Network value must be one of: "tcp", "tcp4", "tcp6", "unix" or "unixpacket".
#                                 Type: string
#
# $keep_alive::                   Specifies whether or not TCP keepalive should be used for established TCP connections.
#                                 Defaults to false.
#                                 Type: bool
#
# $keep_alive_period::            Time duration in seconds that a TCP connection will be maintained before keepalive probes start being sent.
#                                 Defaults to 7200 (i.e. 2 hours).
#                                 Type: int
#
define heka::inputs::tcpinput (
  $ensure                       = 'present',
  # Common Input Parameters
  $decoder                      = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit                     = undef,
  $splitter                     = 'HekaFramingSplitter',
  $log_decode_failures          = true,
  # TCP Input
  $address                      = ':514',
  $net                          = 'tcp',
  $keep_alive                   = false,
  $keep_alive_period            = 7200,
  $use_tls                      = false,
  # TLS configuration settings
  $tls_server_name              = undef,
  $tls_cert_file                = undef,
  $tls_key_file                 = undef,
  $tls_client_auth              = 'NoClientCert',
  $tls_ciphers                  = [],
  $tls_insecure_skip_verify     = false,
  $tls_prefer_server_ciphers    = true,
  $tls_session_tickets_disabled = false,
  $tls_session_ticket_key       = undef,
  $tls_min_version              = 'SSL30',
  $tls_max_version              = 'TLS12',
  $tls_client_cafile            = undef,
  $tls_root_cafile              = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $splitter { validate_string($splitter) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # TCP Input
  validate_string($address)
  validate_string($net)
  validate_re($net, '^(tcp|tcp4|tcp6|unix|unixpacket)$')
  validate_bool($keep_alive)
  validate_integer($keep_alive_period)
  validate_bool($use_tls)
  # TLS configuration settings
  if $tls_server_name { validate_string($tls_server_name) }
  if $tls_cert_file { validate_string($tls_cert_file) }
  if $tls_key_file { validate_string($tls_key_file) }
  validate_string($tls_client_auth)
  validate_array($tls_ciphers)
  validate_bool($tls_insecure_skip_verify)
  validate_bool($tls_prefer_server_ciphers)
  validate_bool($tls_session_tickets_disabled)
  validate_string($tls_session_ticket_key)
  validate_string($tls_min_version)
  validate_string($tls_max_version)
  if $tls_client_cafile { validate_string($tls_client_cafile) }
  if $tls_root_cafile { validate_string($tls_root_cafile) }

  $full_name = "tcpinput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/tcpinput.toml.erb"),
  }
}
