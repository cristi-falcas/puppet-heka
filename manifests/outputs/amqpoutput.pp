# Connects to a remote AMQP broker (RabbitMQ) and sends messages to the specified queue.
# The message is serialized if specified, otherwise only the raw payload of the message will be sent.
# As AMQP is dynamically programmable, the broker topology needs to be specified.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Output Parameters::    Check heka::outputs::tcpoutput for the description
#
### Common TLS Parameters::       Check heka::outputs::tcpoutput for the description
#
### AMQP Parameters
#
# $url::                          An AMQP connection string formatted per the RabbitMQ URI Spec.
#                                 Type: string
#
# $exchange::                     AMQP exchange name
#                                 Type: string
#
# $exchange_type::                AMQP exchange type (fanout, direct, topic, or headers).
#                                 Type: string
#
# $exchange_durability::          Whether the exchange should be configured as a durable exchange.
#                                 Defaults to non-durable.
#                                 Type: bool
#
# $exchange_auto_delete::         Whether the exchange is deleted when all queues have finished and there is no publishing.
#                                 Defaults to auto-delete.
#                                 Type: bool
#
# $routing_key::                  The message routing key used to bind the queue to the exchange.
#                                 Defaults to empty string.
#                                 Type: string
#
# $persistent::                   Whether published messages should be marked as persistent or transient.
#                                 Defaults to non-persistent.
#                                 Type: bool
#
# $content_type::                 MIME content type of the payload used in the AMQP header.
#                                 Defaults to "application/hekad".
#                                 Type: string
#
define heka::outputs::amqpoutput (
  $ensure                       = 'present',
  # Common Output Parameters
  $message_matcher              = undef,
  $message_signer               = undef,
  $ticker_interval              = 5,
  $encoder                      = undef,
  $use_framing                  = undef,
  $can_exit                     = undef,
  $use_buffering                = undef,
  # Buffering
  $max_file_size                = undef,
  $max_buffer_size              = undef,
  $full_action                  = undef,
  $cursor_update_count          = undef,
  # AMQP Parameters
  # lint:ignore:parameter_order
  $url,
  $exchange,
  $exchange_type,
  # lint:endignore
  $exchange_durability          = undef,
  $exchange_auto_delete         = undef,
  $routing_key                  = undef,
  $persistent                   = undef,
  $content_type                 = undef,
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
  # AMQP Parameters
  validate_string($url)
  validate_string($exchange)
  validate_re($exchange_type, '^(fanout|direct|topic|headers)$')
  if $exchange_durability { validate_bool($exchange_durability) }
  if $exchange_auto_delete { validate_bool($exchange_auto_delete) }
  if $routing_key { validate_string($routing_key) }
  if $persistent { validate_bool($persistent) }
  if $content_type { validate_string($content_type) }
  if $use_tls { validate_bool($use_tls) }
  # TLS configuration settings
  if $tls_server_name { validate_string($tls_server_name) }
  if $tls_cert_file { validate_string($tls_cert_file) }
  if $tls_key_file { validate_string($tls_key_file) }
  validate_re($tls_client_auth, '^(NoClientCert|RequestClientCert|RequireAnyClientCert|VerifyClientCertIfGiven|RequireAndVerifyClientCert)$')
  validate_array($tls_ciphers)
  validate_bool($tls_insecure_skip_verify)
  validate_bool($tls_prefer_server_ciphers)
  validate_bool($tls_session_tickets_disabled)
  validate_string($tls_session_ticket_key)
  validate_re($tls_min_version, '^(SSL30|TLS10|TLS11|TLS12)$')
  validate_re($tls_max_version, '^(SSL30|TLS10|TLS11|TLS12)$')
  if $tls_client_cafile { validate_string($tls_client_cafile) }
  if $tls_root_cafile { validate_string($tls_root_cafile) }

  $full_name = "amqpoutput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/amqpoutput.toml.erb"),
  }
}
