# HttpListenInput plugins start a webserver listening on the specified address and port. If no decoder is specified data
# in the request body will be populated as the message payload.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Input Parameters::     Check heka::inputs::tcpinput for the description
#
### Common TLS Parameters::       Check heka::outputs::tcpinput for the description
#
### HttpListenInput Parameters
#
# $address::                      An IP address:port on which this plugin will expose a HTTP server.
#                                 Defaults to "127.0.0.1:8325".
#                                 Type: string
#
# $headers::                      It is possible to inject arbitrary HTTP headers into each outgoing response by adding
#                                 a TOML subsection entitled "headers" to you HttpOutput config section.
#                                 All entries in the subsection must be a list of string values.
#                                 Type: subsection
#
# $request_headers::              Add additional request headers as message fields. Defaults to empty list.
#                                 Type: []string
#
# $auth_type::                    If requiring Authentication specify "Basic" or "API".
#                                 To use "API" you must set a header called "X-API-KEY" with the value of the "api_key" config.
#                                 Type: string
#
# $username::                     Username to check against if auth_type = "Basic".
#                                 Type: string
#
# $password::                     Password to check against if auth_type = "Basic".
#                                 Type: string
#
# $ticker_interval::              Time interval (in seconds) between attempts to poll for new data.
#                                 Defaults to 10.
#                                 Type: uint
#
# $success_severity::             Severity level of successful HTTP request.
#                                 Defaults to 6 (information).
#                                 Type: uint
#
# $error_severity::               Severity level of errors, unreachable connections, and non-200 responses of successful HTTP requests.
#                                 Defaults to 1 (alert).
#                                 Type: uint
#
define heka::inputs::httplisteninput (
  $ensure                       = 'present',
  # Common Input Parameters
  $decoder                      = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit                     = undef,
  $splitter                     = undef,
  $log_decode_failures          = true,
  # HttpListenInput Input
  $address                      = '127.0.0.1:8325',
  $headers                      = undef,
  $request_headers              = undef,
  $auth_type                    = undef,
  $username                     = undef,
  $password                     = undef,
  $api_key                      = undef,
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
  # HttpListenInput Input
  validate_string($address)
  if $username { validate_string($username) }
  if $password { validate_string($password) }
  if $auth_type { validate_re($auth_type, '^(Basic|API)$') }
  if $api_key { validate_string($api_key) }
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

  $full_name = "httplisteninput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/httplisteninput.toml.erb"),
  }
}
