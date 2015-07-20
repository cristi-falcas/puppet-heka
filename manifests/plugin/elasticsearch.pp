define heka::plugin::elasticsearch (
  $ensure            = 'present',
  # Common Output Parameters
  $message_matcher,
  $message_signer    = undef,
  $ticker_interval   = undef,
  $encoder           = 'ProtobufEncoder',
  $use_framing       = undef,
  $can_exit          = undef,
  # ElasticSearch Output
  $flush_interval    = 1000,
  $flush_count       = 10,
  $server            = 'http://localhost:9200',
  $connect_timeout   = 0,
  $http_timeout      = 0,
  $http_disable_keepalives      = false,
  $username          = undef,
  $password          = undef,
  $use_tls           = false,
  $use_buffering     = true,
  $queue_max_buffer_size        = 0,
  $queue_full_action = 'shutdown',
  # TLS configuration settings
  $tls_server_name   = undef,
  $tls_cert_file     = undef,
  $tls_key_file      = undef,
  $tls_client_auth   = 'NoClientCert',
  $tls_ciphers       = [],
  $tls_insecure_skip_verify     = false,
  $tls_prefer_server_ciphers    = true,
  $tls_session_tickets_disabled = false,
  $tls_session_ticket_key       = undef,
  $tls_min_version   = 'SSL30',
  $tls_max_version   = 'TLS12',
  $tls_client_cafile = undef,
  $tls_root_cafile   = undef,
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
    content => template("${module_name}/plugin/elasticsearch.toml.erb"),
    ensure  => $ensure,
  }
}
