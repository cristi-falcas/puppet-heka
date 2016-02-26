# Once per ticker interval a CounterFilter will generate a message of type heka .counter-output.
# The payload will contain text indicating the number of messages that matched the filter's message_matcher
# value during that interval (i.e. it counts the messages the plugin received). Every ten intervals an extra
# message (also of type heka.counter-output) goes out, containing an aggregate count and average per second
# throughput of messages received.
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
### CounterFilter Parameters
#
# $ticker_interval::              Interval between generated counter messages, in seconds.
#                                 Defaults to 5.
#                                 Type: int
#
define heka::filter::counterfilter (
  $ensure              = 'present',
  # Common Filter Parameters
  $message_matcher     = undef,
  $message_signer      = undef,
  $ticker_interval     = 5,
  $can_exit            = undef,
  $use_buffering       = undef,
  # Buffering
  $max_file_size       = undef,
  $max_buffer_size     = undef,
  $full_action         = undef,
  $cursor_update_count = undef,
) {
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

  $full_name = "counterfilter_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/counterfilter.toml.erb"),
  }
}
