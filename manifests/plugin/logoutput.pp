define heka::plugin::logoutput (
  $ensure          = 'present',
  # Common Output Parameters
  $message_matcher,
  $message_signer  = undef,
  $ticker_interval = undef,
  $encoder,
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
