# == Class: heka::plugin::tcpoutput
#
# Setup `TcpOutput` to send messages to another Heka instance.
#
# === Parameters
#
# [*host*]
# Host to send to.
#
# [*port*]
# Port to send to.
#
# [*enable*]
# Disable this plugin. Useful for overriding with hiera on an aggregation
# machine that also has `heka::plugin::tcp_input`.
# Default: false
#
# [*matcher_additional*]
# Additional `message_matcher` expressions to filter messages that you
# don't want to send to another host.
# Default: ''
#
define heka::plugin::tcpoutput (
  $ensure            = 'present',
  # Common Output Parameters
  $message_matcher,
  $message_signer    = undef,
  $ticker_interval   = 300,
  $encoder           = 'ProtobufEncoder',
  $use_framing       = undef,
  $can_exit          = undef,
  # TCP Output
  $host              = 'localhost',
  $port              = 514,
  $use_tls           = false,
  $local_address     = undef,
  $keep_alive        = false,
  $keep_alive_period = 7200,
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
  validate_integer($ticker_interval)
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  # TCP Output
  validate_string($host)
  validate_integer($port)
  validate_bool($use_tls)
  validate_bool($keep_alive)
  validate_integer($keep_alive_period)
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

  $plugin_name = "tcpoutput_${name}"
  heka::snippet { $plugin_name:
    content => template("${module_name}/plugin/tcpoutput.toml.erb"),
    ensure  => $ensure,
  }
}
