# Output plugin that delivers Heka message data to a listening TCP connection. Can be used to deliver
# messages from a local running Heka agent to a remote Heka instance set up as an aggregator and/or
# router, or to any other arbitrary listening TCP server that knows how to process the encoded data.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#                                 Type: string
#
### Common Output Parameters ###
#
# $message_matcher::              Boolean expression, when evaluated to true passes the message to the filter for processing.
#                                 Defaults to matching nothing
#                                 Type: string
#
# $message_signer::               The name of the message signer. If specified only messages with this signer are passed to the
#                                 filter for processing.
#                                 Type: string
#
# $ticker_interval::              Frequency (in seconds) that a timer event will be sent to the filter.
#                                 Defaults to not sending timer events.
#                                 Type: string
#
# $encoder::                      Encoder to be used by the output. This should refer to the name of an encoder plugin section that
#                                 is specified elsewhere in the TOML configuration.
#                                 Messages can be encoded using the specified encoder by calling the OutputRunner's Encode() method.
#                                 Type: string
#
# $use_framing::                  Specifies whether or not Heka's Stream Framing should be applied to the binary data returned from
#                                 the OutputRunner's Encode() method.
#                                 Type: bool
#
# $can_exit::                     Whether or not this plugin can exit without causing Heka to shutdown.
#                                 Defaults to false.
#                                 Type: bool
#
### Buffering::
# All of the buffering config options are set to the standard default options, except for
# cursor_update_count, which is set to 50 instead of the standard default of 1.
#
# $use_buffering::                A boolean that decides if buffering is used or not
#                                 Default: false
#                                 Type: bool
#
# $max_file_size::                The maximum size (in bytes) of a single file in the queue buffer.
#                                 When a message would increase a queue file to greater than this size, the message will be written
#                                 into a new file instead.
#                                 Value cannot be zero, if zero is specified the default will instead be used.
#                                 Defaults to 512MiB.
#                                 Type: uint64
#
# $max_buffer_size::              Maximum amount of disk space (in bytes) that the entire queue buffer can consume.
#                                 The action taken when the maximum buffer size is reached is determined by the full_action setting.
#                                 Defaults to 0, or no limit.
#                                 Type: uint64
#
# $full_action::                  The action Heka will take if the queue buffer grows to larger than the maximum specified by
#                                 the max_buffer_size setting. Must be one of the following values:
#                                 - shutdown: Heka will stop all processing and attempt a clean shutdown.
#                                 - drop: Heka will drop the current message and will continue to process future messages.
#                                 - block: Heka will pause message delivery, applying back pressure through the router to the inputs.
#                                          Delivery will resume if and when the queue buffer size reduces to below the specified maximum.
#                                 Defaults to shutdown, although specific plugins might override this default with a default of their own.
#                                 Type: string
#
# $cursor_update_count::          A plugin is responsible for notifying the queue buffer when a message has been processed by
#                                 calling an UpdateCursor method on the PluginRunner. Some plugins call this for every message,
#                                 while others call it only periodically after processing a large batch of messages.
#                                 This setting specifies how many UpdateCursor calls must be made before the cursor location is flushed to disk.
#                                 Value cannot be zero, if zero is specified the default will be used instead.
#                                 Defaults to 1, although specific plugins might override this default with a default of their own.
#                                 Type: uint
#
### TCP Output Parameters ###
# $address::                      An IP address:port to which we will send our output data.
#                                 Type: string
#
# $local_address::                A local IP address to use as the source address for outgoing traffic to this destination.
#                                 Cannot currently be combined with TLS connections.
#                                 Type: string
#
# $keep_alive::                   Specifies whether or not TCP keepalive should be used for established TCP connections.
#                                 Defaults to false.
#                                 Type: bool
#
# $keep_alive_period::            Time duration in seconds that a TCP connection will be maintained before keepalive probes start
#                                 being sent.
#                                 Defaults to 7200 (i.e. 2 hours).
#                                 Type: int
#
# $reconnect_after::              Re-establish the TCP connection after the specified number of successfully delivered messages.
#                                 Defaults to 0 (no reconnection).
#                                 Type: int
#
### TLS Output Parameters ###
#
# $use_tls::                      Specifies whether or not SSL/TLS encryption should be used for the TCP connections.
#                                 Defaults to false.
#                                 Type: bool
#
# $tls_server_name::              Name of the server being requested. Included in the client handshake to support virtual hosting server environments.
#                                 Type: string
#
# $tls_cert_file::                Full filesystem path to the certificate file to be presented to the other side of the connection.
#                                 Type: string
#
# $tls_key_file::                 Full filesystem path to the specified certificate's associated private key file.
#                                 Type: string
#
# $tls_client_auth::              Specifies the server's policy for TLS client authentication.
#                                 Defaults to "NoClientCert".
#                                 Type: string
#
# $tls_ciphers::                  List of cipher suites supported for TLS connections. Earlier suites in the list have priority over
#                                 those following. If omitted, the implementation's default ordering will be used.
#                                 Type: string
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
#                                 Type: string
#
# $tls_min_version::              Specifies the mininum acceptable SSL/TLS version.
#                                 Defaults to SSL30.
#                                 Type: string
#
# $tls_max_version::              Specifies the maximum acceptable SSL/TLS version.
#                                 Defaults to TLS12.
#                                 Type: string
#
# $tls_client_cafile::            File for server to authenticate client TLS handshake. Any client certs recieved by server must
#                                 be chained to a CA found in this PEM file.
#                                 Has no effect when NoClientCert is set.
#                                 Type: string
#
# $tls_root_cafile::              File for client to authenticate server TLS handshake. Any server certs recieved by client must
#                                 be must be chained to a CA found in this PEM file.
#                                 Type: string
#
define heka::outputs::tcpoutput (
  $ensure                       = 'present',
  # Common Output Parameters
  $message_matcher              = undef,
  $message_signer               = undef,
  $ticker_interval              = undef,
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
  $address                      = 'localhost:514',
  $local_address                = undef,
  $keep_alive                   = false,
  $keep_alive_period            = 7200,
  $reconnect_after              = undef,
  # TLS configuration settings
  $use_tls                      = false,
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
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
  # TCP Output
  validate_string($address)
  if $local_address { validate_string($local_address) }
  validate_bool($keep_alive)
  validate_integer($keep_alive_period)
  if $reconnect_after { validate_integer($reconnect_after) }
  validate_bool($use_tls)
  if $local_address and $use_tls { fail('Cannot currently combine $local_address with TLS connections.') }
  # TLS configuration settings
  if $use_tls { validate_string($tls_server_name) }
  if $use_tls { validate_string($tls_cert_file) }
  if $use_tls { validate_string($tls_key_file) }
  validate_re($tls_client_auth, '^(NoClientCert|RequestClientCert|RequireAnyClientCert|VerifyClientCertIfGiven|RequireAndVerifyClientCert)$')
  validate_array($tls_ciphers)
  validate_bool($tls_insecure_skip_verify)
  validate_bool($tls_prefer_server_ciphers)
  validate_bool($tls_session_tickets_disabled)
  if $tls_session_ticket_key { validate_string($tls_session_ticket_key) }
  validate_re($tls_min_version, '^(SSL30|TLS10|TLS11|TLS12)$')
  validate_re($tls_max_version, '^(SSL30|TLS10|TLS11|TLS12)$')
  if $tls_client_cafile { validate_string($tls_client_cafile) }
  if $tls_root_cafile { validate_string($tls_root_cafile) }

  $full_name = "tcpoutput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/tcpoutput.toml.erb"),
  }
}
