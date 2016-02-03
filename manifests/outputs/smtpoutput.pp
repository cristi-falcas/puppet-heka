# Outputs a Heka message in an email. The message subject is the plugin name and the message content
# is controlled by the payload_only setting. The primary purpose is for email alert notifications e.g., PagerDuty.
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

define heka::outputs::smtpoutput (
  $ensure          = 'present',
  # Common Output Parameters
  $message_matcher,
  $message_signer  = undef,
  $ticker_interval = 300,
  $encoder         = 'ProtobufEncoder',
  $use_framing     = undef,
  $can_exit        = undef,
  # SMTP Output
  $send_from       = "heka@${::fqdn}",
  $send_to         = "root@${::fqdn}",
  $subject         = 'Heka [SmtpOutput]',
  $host            = '127.0.0.1:25',
  $auth            = 'none',
  $user            = undef,
  $password        = undef,
  $send_interval   = 0,
) {
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  validate_integer($ticker_interval)
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  # SMTP Output
  validate_string($send_from)
#  validate_array($send_to)
  validate_string($subject)
  validate_string($host)
  validate_string($auth)
  if $user { validate_string($user) }
  if $password { validate_string($password) }
  validate_integer($send_interval)

  $plugin_name = "smtpoutput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/smtpoutput.toml.erb"),
  }
}
