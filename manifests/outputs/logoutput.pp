# Logs messages to stdout using Go’s log package.
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
#                                Messages can be encoded using the specified encoder by calling the OutputRunner’s Encode() method.
#
# $use_framing::                 Specifies whether or not Heka’s Stream Framing should be applied to the binary data returned from
#                                the OutputRunner’s Encode() method.
#
# $can_exit::                    Whether or not this plugin can exit without causing Heka to shutdown. Defaults to false.
#

define heka::outputs::logoutput (
  $ensure          = 'present',
  # Common Output Parameters
  $message_matcher = 'TRUE',
  $message_signer  = undef,
  $ticker_interval = undef,
  $encoder         = 'PayloadEncoder',
  $use_framing     = undef,
  $can_exit        = undef,
) {
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }

  $plugin_name = "logoutput_${name}"
  heka::snippet { $plugin_name:
    content => template("${module_name}/plugin/logoutput.toml.erb"),
    ensure  => $ensure,
  }
}
