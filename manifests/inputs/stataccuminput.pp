# Provides an implementation of the StatAccumulator interface which other plugins can use to submit
# Stat objects for aggregation and roll-up. Accumulates these stats and then periodically emits a
# "stat metric" type message containing aggregated information about the stats received since the last
# generated message.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### StatAccumInput Parameters ###
#
# $emit_in_payload::              Specifies whether or not the aggregated stat information should be emitted
#                                 in the payload of the generated messages, in the format accepted by the carbon
#                                 portion of the graphite graphing software.
#                                 Defaults to true.
#
# $emit_in_fields::               Specifies whether or not the aggregated stat information should be emitted in the
#                                 message fields of the generated messages.
#                                 NOTE: At least one of 'emit_in_payload' or 'emit_in_fields' must be true or it will
#                                 be considered a configuration error and the input won't start.
#                                 Defaults to false.
#
# $percent_threshold::            Percent threshold to use for computing "upper_N%" type stat values.
#                                 Defaults to 90.
#
# $ticker_interval::              Time interval (in seconds) between generated output messages.
#                                 Defaults to 10.
#
# $message_type::                 String value to use for the Type value of the emitted stat messages.
#                                 Defaults to "heka.statmetric".
#
# $legacy_namespaces::            If set to true, then use the older format for namespacing counter stats, with rates recorded
#                                 under stats.<counter_name> and absolute count recorded under stats_counts.<counter_name>.
#                                 See statsd metric namespacing.
#                                 Defaults to false.
#
# $global_prefix::                Global prefix to use for sending stats to graphite.
#                                 Defaults to "stats".
#
# $counter_prefix::               Secondary prefix to use for namespacing counter metrics. Has no impact unless legacy_namespaces
#                                 is set to false.
#                                 Defaults to "counters".
#
# $timer_prefix::                 Secondary prefix to use for namespacing timer metrics.
#                                 Defaults to "timers".
#
# $gauge_prefix::                 Secondary prefix to use for namespacing gauge metrics.
#                                 Defaults to "gauges".
#
# $statsd_prefix::                Prefix to use for the statsd numStats metric.
#                                 Defaults to "statsd".
#
# $delete_idle_stats::            Don't emit values for inactive stats instead of sending 0 or in the case of gauges,
#                                 sending the previous value.
#                                 Defaults to false.
#
define heka::inputs::stataccuminput (
  $ensure            = 'present',
  # StatAccumInput Parameters
  $emit_in_payload   = undef,
  $emit_in_fields    = undef,
  $percent_threshold = undef,
  $ticker_interval   = undef,
  $message_type      = undef,
  $legacy_namespaces = undef,
  $global_prefix     = undef,
  $counter_prefix    = undef,
  $timer_prefix      = undef,
  $gauge_prefix      = undef,
  $statsd_prefix     = undef,
  $delete_idle_stats = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # StatAccumInput Parameters
  if $emit_in_payload { validate_bool($emit_in_payload) }
  if $emit_in_fields { validate_bool($emit_in_fields) }
  if $percent_threshold { validate_integer($percent_threshold) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $message_type { validate_string($message_type) }
  if $legacy_namespaces { validate_bool($legacy_namespaces) }
  if $global_prefix { validate_string($global_prefix) }
  if $counter_prefix { validate_string($counter_prefix) }
  if $timer_prefix { validate_string($timer_prefix) }
  if $gauge_prefix { validate_string($gauge_prefix) }
  if $statsd_prefix { validate_string($statsd_prefix) }
  if $delete_idle_stats { validate_bool($delete_idle_stats) }

  $full_name = "stataccuminput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/stataccuminput.toml.erb"),
  }
}
