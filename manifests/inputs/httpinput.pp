# HttpInput plugins intermittently poll remote HTTP URLs for data and populate message objects based on the results\
# of the HTTP interactions.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Input Parameters::     Check heka::inputs::tcpinput for the description
#
### HttpInput Parameters
#
# $url::                          A HTTP URL which this plugin will regularly poll for data. This option cannot be used
#                                 with the urls option.
#                                 No default URL is specified.
#                                 Type: string
#
# $urls::                         An array of HTTP URLs which this plugin will regularly poll for data.
#                                 This option cannot be used with the url option.
#                                 No default URLs are specified.
#                                 Type: array
#
# $method::                       The HTTP method to use for the request. Defaults to "GET".
#                                 Type: string
#
# $headers::                      Subsection defining headers for the request.
#                                 By default the User-Agent header is set to "Heka"
#                                 Type: subsection
#
# $body::                         The request body (e.g. for an HTTP POST request).
#                                 No default body is specified.
#                                 Type: string
#
# $username::                     The username for HTTP Basic Authentication.
#                                 No default username is specified.
#                                 Type: string
#
# $password::                     The password for HTTP Basic Authentication.
#                                 No default password is specified.
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
define heka::inputs::httpinput (
  $ensure               = 'present',
  # Common Input Parameters
  $decoder              = 'ProtobufDecoder',
  $synchronous_decode   = false,
  $send_decode_failures = false,
  $can_exit             = undef,
  $splitter             = undef,
  $log_decode_failures  = true,
  # HTTP Input
  $url                  = undef,
  $urls                 = undef,
  $method               = 'GET',
  $headers              = { 'user-agent' => 'Heka' },
  $body                 = undef,
  $username             = undef,
  $password             = undef,
  $ticker_interval      = undef,
  $success_severity     = undef,
  $error_severity       = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $splitter { validate_string($splitter) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # HTTP Input
  if !($url or $urls) { fail('$url or $urls param must be provided') }
  if ($url and $urls) { fail('$url and $urls params are mutually exclusive') }
  validate_string($url, $method)
  if $body { validate_string($body) }
  if $username { validate_string($username) }
  if $password { validate_string($password) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $success_severity { validate_integer($success_severity) }
  if $error_severity { validate_integer($error_severity) }

  $full_name = "httpinput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/httpinput.toml.erb"),
  }
}
