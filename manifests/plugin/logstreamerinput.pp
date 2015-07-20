# == Class: heka::plugin::logstreamerinput
#
# Setup `LogstreamerInput` plugin
#
# === Parameters
#
# TODO: Add all parameters from http://hekad.readthedocs.org/en/v0.9.2/config/inputs/logstreamer.html

define heka::plugin::logstreamerinput (
  $ensure               = 'present',
  # Common Input Parameters
  $splitter             = undef,
  $decoder              = undef,
  $synchronous_decode   = undef,
  $send_decode_failures = undef,
  $can_exit             = undef,
  # LogstreamerInput specific Parameters
  $log_directory,
  $file_match,
  $hostname             = undef,
  $oldest_duration      = undef,
  $journal_directory    = undef,
  $rescan_interval      = undef,
  $priority             = undef,
  $differentiator       = undef,
  $translation          = undef,
) {
  # Common Input Parameters
  if $splitter { validate_string($splitter) }
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  # LogstreamerInput specific Parameters
  if $hostname { validate_string($hostname) }
  if $oldest_duration { validate_string($oldest_duration) }
  if $journal_directory { validate_string($hostname) }
  if $log_directory { validate_string($log_directory) }
  if $rescan_interval { validate_integer($rescan_interval) }
  if $file_match { validate_string($file_match) }
  if $priority { validate_array($priority) }
  if $differentiator { validate_array($differentiator) }
  if $translation { validate_hash($translation) }

  $plugin_name = "logstreamerinput_${name}"
  heka::snippet { $plugin_name:
    content => template("${module_name}/plugin/logstreamerinput.toml.erb"),
    ensure  => $ensure,
  }
}
