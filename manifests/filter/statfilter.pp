# Filter plugin that accepts messages of a specfied form and uses extracted message data to feed statsd-style numerical
# metrics in the form of Stat objects to a StatAccumulator.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Filter Parameters::    Check heka::filter::sandboxfilter for the description
#
### Buffering::                   Check heka::filter::sandboxfilter for the description
#
### Stat Filter Parameters
#
# $metric::                       Subsection defining a single metric to be generated. Both the name and value fields for each
#                                 metric support interpolation of message field values (from 'Type', 'Hostname', 'Logger', 'Payload',
#                                 or any dynamic field name) with the use of %% delimiters, so %Hostname% would be replaced by the message's
#                                 Hostname field, and %Foo% would be replaced by the first value of a dynamic field called "Foo":
#                                 - type:: Metric type, supports "Counter", "Timer", "Gauge".
#                                 - name:: Metric name, must be unique.
#                                 - value:: Expression representing the (possibly dynamic) value that the StatFilter should emit for each received message.
#                                 - replace_dot:: Replace all dots . per an underscore _ during the string interpolation.
#                                                 It's useful if you output this result in a graphite instance.
#                                 Type: hash of hashes, or array of hash of hashes: $metric = {'bandwidth' => {'type' => 'Counter', name => 'httpd.bytes.%Hostname%'}}
#
# $stat_accum_name::              Name of a StatAccumInput instance that this StatFilter will use as its StatAccumulator for submitting generate stat values.
#                                 Defaults to "StatAccumInput".
#                                 Type: string
#
define heka::filter::statfilter (
  $ensure              = 'present',
  # Common Filter Parameters
  $message_matcher     = undef,
  $message_signer      = undef,
  $ticker_interval     = undef,
  $can_exit            = undef,
  $use_buffering       = undef,
  # Buffering
  $max_file_size       = undef,
  $max_buffer_size     = undef,
  $full_action         = undef,
  $cursor_update_count = undef,
  # Stat Filter Parameters
  # lint:ignore:parameter_order
  $metric,
  # lint:endignore
  $stat_accum_name     = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Filter Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $can_exit { validate_bool($can_exit) }
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
  # Stat Filter Parameters
  if $stat_accum_name { validate_string($stat_accum_name) }

  $full_name = "statfilter_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/statfilter.toml.erb"),
  }
}
