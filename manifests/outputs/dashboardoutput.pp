# Specialized output plugin that listens for certain Heka reporting message types and generates JSON data
# which is made available via HTTP for use in web based dashboards and health reports.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $message_matcher::             Defaults to
#                                "Type == 'heka.all-report' || Type == 'heka.sandbox-output' || Type == 'heka.sandbox-terminated'".
#                                Not recommended to change this unless you know what you're doing.
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
# $host::                        An IP address on which we will serve output via HTTP. Defaults to "0.0.0.0".
#
# $port::                        An IP port on which we will serve output via HTTP. Defaults to "4352".
#
# $working_directory::           File system directory into which the plugin will write data files and from which it will serve
#                                HTTP. The Heka process must have read / write access to this directory. Relative paths will be
#                                evaluated relative to the Heka base directory. Defaults to $(BASE_DIR)/dashboard.
#
# $static_directory::            File system directory where the Heka dashboard source code can be found. The Heka process must have
#                                read access to this directory. Relative paths will be evaluated relative to the Heka base
#                                directory.
#                                Defaults to ${SHARE_DIR}/dasher.
#
# $headers::                     It is possible to inject arbitrary HTTP headers into each outgoing response by adding a TOML
#                                subsection entitled "headers" to you HttpOutput config section. All entries in the subsection
#                                must be a list of string values.
#

define heka::outputs::dashboardoutput (
  $ensure            = 'present',
  # Common Output Parameters
  $message_matcher   = undef,
  $message_signer    = undef,
  $ticker_interval   = 5,
  $encoder           = undef,
  $use_framing       = undef,
  $can_exit          = undef,
  # Dashboard Output
  $host              = '0.0.0.0',
  $port              = 4352,
  $working_directory = undef,
  $static_directory  = undef,
  $headers           = undef,
) {
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  validate_integer($ticker_interval)
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  # Dashboard Output
  validate_string($host)
  validate_integer($port)
  if $working_directory { validate_string($working_directory) }
  if $static_directory { validate_string($static_directory) }
  if $headers { validate_string($headers) }

  $plugin_name = "dashboard_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/dashboard.toml.erb"),
  }
}
