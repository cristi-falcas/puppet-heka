# Connects to a remote AMQP broker (RabbitMQ) and retrieves messages from the specified queue.
# As AMQP is dynamically programmable, the broker topology needs to be specified in the plugin configuration.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#                                 Type: string
#
### Common Input Parameters::     Check heka::inputs::tcpinput for the description
#
### Configuring Restarting Behavior::
#
# $retries::                      If set tot true, it will configure restarting behaviour.
#                                 A sub-section that specifies the settings to be used for restart behavior.
#                                 See Configuring Restarting Behavior
#                                 Default: false
#                                 Type: bool
#
# $retries_max_jitter::           The longest jitter duration to add to the delay between restarts.
#                                 Jitter up to 500ms by default is added to every delay to ensure more even restart attempts over time.
#                                 Type: string
#
# $retries_max_delay::            The longest delay between attempts to restart the plugin.
#                                 Defaults to 30s (30 seconds).
#                                 Type: string
#
# $retries_delay::                The starting delay between restart attempts. This value will be the initial starting delay
#                                 for the exponential back-off, and capped to be no larger than the max_delay.
#                                 Defaults to 250ms.
#                                 Type: string
#
# $retries_max_retries::          Maximum amount of times to attempt restarting the plugin before giving up and exiting the plugin.
#                                 Use 0 for no retry attempt, and -1 to continue trying forever (note that this will cause
#                                 hekad to halt possibly forever if the plugin cannot be restarted).
#                                 Defaults to -1.
#                                 Type: int
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
# $prefetch_count::               How many messages to fetch at once before message acks are sent.
#                                 See RabbitMQ performance measurements for help in tuning this number.
#                                 Defaults to 2.
#                                 Type: int
#
# $queue::                        Name of the queue to consume from, an empty string will have the broker generate a name for the queue.
#                                 Defaults to empty string.
#                                 Type: string
#
# $queue_durability::             Whether the queue is durable or not.
#                                 Defaults to non-durable.
#                                 Type: bool
#
# $queue_exclusive::              Whether the queue is exclusive (only one consumer allowed) or not.
#                                 Defaults to non-exclusive.
#                                 Type: bool
#
# $queue_auto_delete::            Whether the queue is deleted when the last consumer un-subscribes.
#                                 Defaults to auto-delete.
#                                 Type: bool
#
# $queue_ttl::                    Allows ability to specify TTL in milliseconds on Queue declaration for expiring messages.
#                                 Defaults to undefined/infinite.
#                                 Type: string
#
# $read_only::                    Whether the AMQP user is read-only. If this is true the exchange, queue and binding must
#                                 be declared before starting Heka.
#                                 Defaults to false.
#                                 Type: bool
#
### Common TLS Parameters::       Check heka::outputs::tcpoutput for the description
#
# $use_tls::                      Specifies whether or not SSL/TLS encryption should be used for the TCP connections.
#                                 Defaults to false.
#                                 Type: bool
#
define heka::inputs::amqpinput (
  $ensure                       = 'present',
  # Common Input Parameters
  $decoder                      = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit                     = undef,
  $splitter                     = undef,
  $log_decode_failures          = true,
  # Retries Parameters
  $retries                      = false,
  $retries_max_jitter           = '500ms',
  $retries_max_delay            = '30s',
  $retries_delay                = '250ms',
  $retries_max_retries          = -1,
  # AMQP Parameters
  # lint:ignore:parameter_order
  $url,
  $exchange,
  $exchange_type,
  # lint:endignore
  $exchange_durability          = undef,
  $exchange_auto_delete         = undef,
  $routing_key                  = undef,
  $prefetch_count               = undef,
  $queue                        = undef,
  $queue_durability             = undef,
  $queue_exclusive              = undef,
  $queue_auto_delete            = undef,
  $queue_ttl                    = undef,
  $read_only                    = undef,
  $use_tls                      = undef,
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
  # Retries Parameters
  if $retries { validate_bool($retries) }
  if $retries_max_jitter { validate_string($retries_max_jitter) }
  if $retries_max_delay { validate_string($retries_max_delay) }
  if $retries_delay { validate_string($retries_delay) }
  if $retries_max_retries { validate_integer($retries_max_retries) }
  # AMQP Parameters
  validate_string($url)
  validate_string($exchange)
  validate_re($exchange_type, '^(fanout|direct|topic|headers)$')
  if $exchange_durability { validate_bool($exchange_durability) }
  if $exchange_auto_delete { validate_bool($exchange_auto_delete) }
  if $routing_key { validate_string($routing_key) }
  if $prefetch_count { validate_integer($prefetch_count) }
  if $queue { validate_string($queue) }
  if $queue_durability { validate_bool($queue_durability) }
  if $queue_exclusive { validate_bool($queue_exclusive) }
  if $queue_auto_delete { validate_bool($queue_auto_delete) }
  if $queue_ttl { validate_integer($queue_ttl) }
  if $read_only { validate_bool($read_only) }
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

  $full_name = "amqpinput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/amqpinput.toml.erb"),
  }
}
