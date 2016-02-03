# Output plugin that uses HTTP or UDP to insert records into an ElasticSearch database.
# Note that it is up to the specified encoder to both serialize the message into a JSON
# structure and to prepend that with the appropriate ElasticSearch BulkAPI indexing JSON.
# Usually this output is used in conjunction with an ElasticSearch-specific encoder plugin,
# such as ElasticSearch JSON Encoder, ElasticSearch Logstash V0 Encoder, or ElasticSearch Payload Encoder.
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
#                                Messages can be encoded using the specified encoder by calling the OutputRunner's Encode() method.
#
# $use_framing::                 Specifies whether or not Heka's Stream Framing should be applied to the binary data returned from
#                                the OutputRunner's Encode() method.
#
# $can_exit::                    Whether or not this plugin can exit without causing Heka to shutdown. Defaults to false.
#
# tbc

define heka::outputs::elasticsearchoutput (
  $ensure                       = 'present',
  # Common Output Parameters
  $message_matcher,
  $message_signer               = undef,
  $ticker_interval              = undef,
  $encoder                      = 'ProtobufEncoder',
  $use_framing                  = undef,
  $can_exit                     = undef,
  # ElasticSearch Output
  $flush_interval               = 1000,
  $flush_count                  = 10,
  $server                       = 'http://localhost:9200',
  $connect_timeout              = 0,
  $http_timeout                 = 0,
  $http_disable_keepalives      = false,
  $username                     = undef,
  $password                     = undef,
  $use_tls                      = false,
  $use_buffering                = true,
  $queue_max_buffer_size        = 0,
  $queue_full_action            = 'shutdown',
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
  if $ticker_interval { validate_integer($ticker_interval) }
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  # ElasticSearch Output
  validate_integer($flush_interval)
  validate_integer($flush_count)
  validate_string($server)
  validate_integer($connect_timeout)
  validate_integer($http_timeout)
  validate_bool($http_disable_keepalives)
  if $username { validate_string($username) }
  if $password { validate_string($password) }
  validate_bool($use_tls)
  validate_bool($use_buffering)
  validate_integer($queue_max_buffer_size)
  validate_string($queue_full_action)
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

  $plugin_name = "elasticsearch_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/elasticsearch.toml.erb"),
  }
}
