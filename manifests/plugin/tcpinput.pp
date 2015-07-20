# == Class: heka::plugin::tcpinput
#
# Setup `TcpInput` to receive messages from another Heka instance.
#
# === Parameters
#
# [*port*]
# Port to listen on.
#
# [*host*]
# Host to listen on.
# Default: '' (all interfaces)
#
define heka::plugin::tcpinput (
  $ensure        = 'present',
  # Common Input Parameters
  $decoder       = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit      = undef,
  $splitter      = 'HekaFramingSplitter',
  # TCP Input
  $host          = '',
  $port          = '514',
  $use_tls       = false,
  $net           = 'tcp',
  $keep_alive    = false,
  $keep_alive_period            = 7200,
  # TLS configuration settings
  $tls_server_name              = undef,
  $tls_cert_file = undef,
  $tls_key_file  = undef,
  $tls_client_auth              = 'NoClientCert',
  $tls_ciphers   = [],
  $tls_insecure_skip_verify     = false,
  $tls_prefer_server_ciphers    = true,
  $tls_session_tickets_disabled = false,
  $tls_session_ticket_key       = undef,
  $tls_min_version              = 'SSL30',
  $tls_max_version              = 'TLS12',
  $tls_client_cafile            = undef,
  $tls_root_cafile              = undef,
) {
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  validate_string($splitter)
  # TCP Input
  validate_string($host)
  validate_integer($port)
  validate_bool($use_tls)
  validate_string($net)
  validate_bool($keep_alive)
  validate_integer($keep_alive_period)
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

  $plugin_name = "tcpinput_${name}"
  heka::snippet { $plugin_name:
    content => template("${module_name}/plugin/tcpinput.toml.erb"),
    ensure  => $ensure,
  }
}
