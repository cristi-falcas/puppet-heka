# == Class: heka::plugin::dashboard
#
# Setup `DashboardOutput`.
#
# === Parameters
#
# [*host*]
# Host to listen on.
# Default: 127.0.0.1
#
# [*port*]
# Port to listen on.
# Default: 4352
#
# [*interval*]
# Update interval in seconds.
# Default: 5
#
define heka::plugin::dashboard (
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
    content => template("${module_name}/plugin/dashboard.toml.erb"),
    ensure  => $ensure,
  }
}
