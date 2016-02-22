# Outputs a Heka message in an email. The message subject is the plugin name and the message content
# is controlled by the payload_only setting. The primary purpose is for email alert notifications e.g., PagerDuty.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Output Parameters::    Check heka::outputs::tcpoutput for the description
#
### SMTP Output
#
# $send_from::                    The email address of the sender.
#                                 Default: "heka@localhost.localdomain"
#                                 Type: string
#
# $send_to::                      An array of email addresses where the output will be sent to.
#                                 Type: []string
#
# $subject::                      Custom subject line of email.
#                                 Default: "Heka [SmtpOutput]"
#                                 Type: string
#
# $host::                         SMTP host to send the email to.
#                                 Default: "127.0.0.1:25"
#                                 Type: string
#
# $auth::                         SMTP authentication type: "none", "Plain", "CRAMMD5".
#                                 Default: "none"
#                                 Type: string
#
# $user::                         SMTP user name
#                                 Type: string
#
# $password::                     SMTP user password
#                                 Type: string
#
# $send_interval::                Minimum time interval between each email, in seconds. First email in an interval goes out immediately,
#                                 subsequent messages in the same interval are concatenated and all sent when the interval expires.
#                                 Defaults to 0, meaning all emails are sent immediately.
#                                 Type: uint
#
define heka::outputs::smtpoutput (
  $ensure              = 'present',
  # Common Output Parameters
  $message_matcher     = undef,
  $message_signer      = undef,
  $ticker_interval     = 5,
  $encoder             = undef,
  $use_framing         = undef,
  $can_exit            = undef,
  $use_buffering       = undef,
  # Buffering
  $max_file_size       = undef,
  $max_buffer_size     = undef,
  $full_action         = undef,
  $cursor_update_count = undef,
  # SMTP Output
  $send_from           = "heka@${::fqdn}",
  $send_to             = "root@${::fqdn}",
  $subject             = 'Heka [SmtpOutput]',
  $host                = '127.0.0.1:25',
  $auth                = 'none',
  $user                = undef,
  $password            = undef,
  $send_interval       = 0,
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
  # SMTP Output
  validate_string($send_from)
  validate_string($subject)
  validate_string($host)
  validate_string($auth)
  if $user { validate_string($user) }
  if $password { validate_string($password) }
  if $send_interval { validate_integer($send_interval) }

  $full_name = "smtpoutput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/smtpoutput.toml.erb"),
  }
}
