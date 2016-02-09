# Output plugin that uses HTTP or UDP to insert records into an ElasticSearch database.
# Note that it is up to the specified encoder to both serialize the message into a JSON
# structure and to prepend that with the appropriate ElasticSearch BulkAPI indexing JSON.
# Usually this output is used in conjunction with an ElasticSearch-specific encoder plugin,
# such as ElasticSearch JSON Encoder, ElasticSearch Logstash V0 Encoder, or ElasticSearch Payload Encoder.
#
# === Parameters:
#
# $ensure::                     This is used to set the status of the config file: present or absent
#
### Common Output Parameters::  Check heka::outputs::tcpoutput for the description
#
# $flush_interval::             Interval at which accumulated messages should be bulk indexed into ElasticSearch,
#                               in milliseconds.
#                               Defaults to 1000 (i.e. one second).
#
# $flush_count::                Number of messages that, if processed, will trigger them to be bulk indexed into ElasticSearch.
#                               Defaults to 10.
#
# $server::                     ElasticSearch server URL. Supports http://, https:// and udp:// urls.
#                               Defaults to "http://localhost:9200".
#
# $connect_timeout::            Time in milliseconds to wait for a server name resolving and connection to ES.
#                               It's included in an overall time (see 'http_timeout' option), if they both are set.
#                               Default is 0 (no timeout).
#
# $http_timeout::               Time in milliseconds to wait for a response for each http post to ES.
#                               This may drop data as there is currently no retry.
#                               Default is 0 (no timeout).
#
# $http_disable_keepalives::    Specifies whether or not re-using of established TCP connections to ElasticSearch should be disabled.
#                               Defaults to false, that means using both HTTP keep-alive mode and TCP keep-alives.
#                               Set it to true to close each TCP connection after 'flushing' messages to ElasticSearch.
#
# $username::                   The username to use for HTTP authentication against the ElasticSearch host.
#                               Defaults to "" (i. e. no authentication).
#
# $password::                   The password to use for HTTP authentication against the ElasticSearch host.
#                               Defaults to "" (i. e. no authentication).
#
# $use_tls::                     Specifies whether or not SSL/TLS encryption should be used for the TCP connections.
#                                Defaults to false.
#
### Common TLS Parameters::      Check heka::outputs::tcpoutput for the description
#
define heka::outputs::elasticsearchoutput (
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
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
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
