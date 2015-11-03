# Output plugin that delivers Heka message data to a listening TCP connection. Can be used to deliver
# messages from a local running Heka agent to a remote Heka instance set up as an aggregator and/or
# router, or to any other arbitrary listening TCP server that knows how to process the encoded data.
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
# $address::                     An IP address:port to which we will send our output data.
#
# $use_tls::                     Specifies whether or not SSL/TLS encryption should be used for the TCP connections.
#                                Defaults to false.
#
# $local_address::               A local IP address to use as the source address for outgoing traffic to this destination.
#                                Cannot currently be combined with TLS connections.
#
# $keep_alive::                  Specifies whether or not TCP keepalive should be used for established TCP connections.
#                                Defaults to false.
#
# $keep_alive_period::           Time duration in seconds that a TCP connection will be maintained before keepalive probes start
#                                being sent.
#                                Defaults to 7200 (i.e. 2 hours).
#
# $queue_max_buffer_size::
#
# $queue_full_action::
#
# $use_buffering::               Buffer records to a disk-backed buffer on the Heka server before sending them out over the TCP
#                                connection.
#                                Defaults to true.
#
# $buffering::                   All of the buffering config options are set to the standard default options, except for
#                                cursor_update_count, which is set to 50 instead of the standard default of 1.
#
# $reconnect_after::             Re-establish the TCP connection after the specified number of successfully delivered messages.
#                                Defaults to 0 (no reconnection).
#

define heka::outputs::tcpoutput (
  $ensure                       = 'present',
  # Common Output Parameters
  $message_matcher,
  $message_signer               = undef,
  $ticker_interval              = 300,
  $encoder                      = 'ProtobufEncoder',
  $use_framing                  = undef,
  $can_exit                     = undef,
  # TCP Output
  $address                      = 'localhost:514',
  $use_tls                      = false,
  $local_address                = undef,
  $keep_alive                   = false,
  $keep_alive_period            = 7200,
  $queue_max_buffer_size        = 0,
  $queue_full_action            = 'shutdown',
  $use_buffering                = undef,
  $buffering                    = undef,
  $reconnect_after              = undef,
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
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  validate_integer($ticker_interval)
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  # TCP Output
  validate_string($address)
  validate_bool($use_tls)
  validate_bool($keep_alive)
  validate_integer($keep_alive_period)
  validate_integer($queue_max_buffer_size)
  validate_string($queue_full_action)
  if $use_buffering { validate_bool($use_buffering) }
  if $buffering { validate_string($buffering) }
  if $reconnect_after { validate_integer($reconnect_after) }
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

  $plugin_name = "tcpoutput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/tcpoutput.toml.erb"),
  }
}
