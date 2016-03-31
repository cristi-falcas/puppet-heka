# Listens for statsd protocol counter, timer, or gauge messages on a UDP port, and generates Stat objects
# that are handed to a StatAccumulator for aggregation and processing.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### StatsdInput Parameters ###
#
# $address::                      An IP address:port on which this plugin will expose a statsd server.
#                                 Defaults to "127.0.0.1:8125".
#
# $stat_accum_name::              Name of a StatAccumInput instance that this StatsdInput will use as its
#                                 StatAccumulator for submitting received stat values.
#                                 Defaults to "StatAccumInput".
#
# $max_msg_size::                 Size of a buffer used for message read from statsd. In some cases, when statsd
#                                 sends a lots in single message of stats it's required to boost this value.
#                                 All over-length data will be truncated without raising an error.
#                                 Defaults to 512.
#
define heka::inputs::statsdinput (
  $ensure          = 'present',
  # StatsdInput Parameters
  $address         = '127.0.0.1:8125',
  $stat_accum_name = 'StatAccumInput',
  $max_msg_size    = 512,
) {
  validate_re($ensure, '^(present|absent)$')
  # StatsdInput Parameters
  validate_string($address, $stat_accum_name)
  validate_integer($max_msg_size)

  $full_name = "statsdinput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/statsdinput.toml.erb"),
  }
}
