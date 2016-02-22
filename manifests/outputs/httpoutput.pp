# A very simple output plugin that uses HTTP GET, POST, or PUT requests to deliver data to an HTTP endpoint.
# When using POST or PUT request methods the encoded output will be uploaded as the request body.
# When using GET the encoded output will be ignored.
#
# This output doesn't support any request batching; each received message will generate an HTTP request.
# Batching can be achieved by use of a filter plugin that accumulates message data, periodically emitting a single
# message containing the batched, encoded HTTP request data in the payload. An HttpOutput can then be configured to
# capture these batch messages, using a Payload Encoder to extract the message payload.
#
# For now the HttpOutput only supports statically defined request parameters (URL, headers, auth, etc.).
# Future iterations will provide a mechanism for dynamically specifying these values on a per-message basis.
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
### HTTP Output Parameters
#
# $address::                      URL address of HTTP server to which requests should be sent. Must begin with "http://" or "https://".
#                                 Type: string
#
# $method::                       HTTP request method to use, must be one of GET, POST, or PUT.
#                                 Defaults to POST.
#                                 Type: string
#
# $username::                     If specified, HTTP Basic Auth will be used with the provided user name.
#                                 Type: string
#
# $password::                     If specified, HTTP Basic Auth will be used with the provided password.
#                                 Type: string
#
# $headers::                      It is possible to inject arbitrary HTTP headers into each outgoing request by adding a TOML subsection
#                                 entitled "headers" to you HttpOutput config section.
#                                 All entries in the subsection must be a list of string values.
#                                 Type: subsection
#
# $http_timeout::                 Time in milliseconds to wait for a response for each http request.
#                                 This may drop data as there is currently no retry.
#                                 Default is 0 (no timeout)
#                                 Type: uint
#
define heka::outputs::httpoutput (
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
  # HTTP Output Parameters
  $address,
  $method                       = undef,
  $username                     = undef,
  $password                     = undef,
  $headers                      = undef,
  $http_timeout                 = undef,
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
  # HTTP Parameters
  if $address { validate_string($address) }
  if $method { validate_re($method, '^(GET|POST|PUT)$') }
  if $username { validate_string($username) }
  if $password { validate_string($password) }
  if $headers { validate_hash($headers) }
  if $http_timeout { validate_integer($http_timeout) }
  # TLS configuration settings
  if $use_tls { validate_bool($use_tls) }
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

  $full_name = "httpoutput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/httpoutput.toml.erb"),
  }
}
