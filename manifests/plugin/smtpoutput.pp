define heka::plugin::smtpoutput (
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
    content => template("${module_name}/plugin/smtpoutput.toml.erb"),
    ensure  => $ensure,
  }
}
